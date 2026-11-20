// Formulaire de réservation — vanilla TS, pas de framework.
export interface BookingFormInput {
  title: string;
  start: string; // date ISO
  end: string; // date ISO
}

export async function submitBooking(input: BookingFormInput): Promise<void> {
  if (input.title.trim() === "") {
    throw new Error("Le titre est obligatoire");
  }

  await fetch("/api/bookings", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });
}
