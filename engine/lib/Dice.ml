let roll sides =
  Random.self_init ();
  Random.int (sides - 1) + 1