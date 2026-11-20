namespace Signups;

public sealed record User
{
    private User(string email, string pseudo)
    {
        Email = email;
        Pseudo = pseudo;
    }

    public string Email { get; }

    public string Pseudo { get; }

    public static User Create(string email, string pseudo) => new(email, pseudo);
}

// Ports de sortie. L'implémentation réelle est SQL ; le doublon en mémoire
// ci-dessous joue la base pour les tests.
public interface IPseudoLookup
{
    bool PseudoTaken(string pseudo);
}

public interface ISignupStore
{
    // Lève PseudoTakenException quand la contrainte unique sur Pseudo est violée.
    void Save(User user);
}

public sealed class PseudoTakenException : Exception
{
    public PseudoTakenException(string pseudo)
        : base($"Violation de la contrainte unique Users.Pseudo : '{pseudo}'.")
    {
    }
}

public class SignupService
{
    private readonly IPseudoLookup _lookups;
    private readonly ISignupStore _store;

    public SignupService(IPseudoLookup lookups, ISignupStore store)
    {
        _lookups = lookups;
        _store = store;
    }

    public void Signup(string email, string pseudo)
    {
        if (_lookups.PseudoTaken(pseudo))
            throw new PseudoTakenException(pseudo);

        _store.Save(User.Create(email, pseudo));
    }
}

public class NightlyImport
{
    private readonly SignupService _signups;

    public NightlyImport(SignupService signups) => _signups = signups;

    public void Import(IEnumerable<(string Email, string Pseudo)> rows)
    {
        foreach (var row in rows)
            _signups.Signup(row.Email, row.Pseudo);
    }
}

// Doublon en mémoire qui joue SQL : PseudoTaken lit, Save fait respecter
// la contrainte unique déclarée dans schema.sql.
public sealed class InMemoryDatabase : IPseudoLookup, ISignupStore
{
    private readonly HashSet<string> _pseudos = new(StringComparer.Ordinal);

    public bool PseudoTaken(string pseudo) => _pseudos.Contains(pseudo);

    public void Save(User user)
    {
        if (_pseudos.Contains(user.Pseudo))
            throw new PseudoTakenException(user.Pseudo);

        _pseudos.Add(user.Pseudo);
    }
}
