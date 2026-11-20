-- État de la base. Ce qui doit y être vrai en production doit être vrai ici.
CREATE TABLE Users (
    Id     UUID         PRIMARY KEY,
    Email  VARCHAR(320) NOT NULL UNIQUE,
    Pseudo VARCHAR(25)  NULL
);
