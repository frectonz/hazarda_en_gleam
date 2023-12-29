import gleam/io
import gleam/erlang
import gleam/int
import gleam/result
import gleam/string
import gleam_community/ansi

type Game {
  Game(secret: Int, guess_count: Int)
}

fn run(game: Game) {
  case
    read_input()
    |> result.map(string.trim)
    |> result.try(to_int)
  {
    Ok(guess) if guess == game.secret ->
      { "You got it in " <> int.to_string(game.guess_count) <> " tries." }
      |> ansi.green
      |> ansi.bold
      |> io.println

    Ok(guess) if guess > game.secret -> {
      "Try a smaller number"
      |> ansi.yellow
      |> io.println

      run(Game(game.secret, game.guess_count + 1))
    }
    Ok(guess) if guess < game.secret -> {
      "Try a bigger number"
      |> ansi.yellow
      |> io.println

      run(Game(game.secret, game.guess_count + 1))
    }

    Ok(_) -> panic as "unreachable"

    Error(InputReadError(_)) -> {
      "\nfailed to read line"
      |> ansi.red
      |> io.println
    }
    Error(IntConversionError) -> {
      "failed to convert to integer"
      |> ansi.red
      |> io.println

      run(game)
    }
  }
}

pub type GameError {
  InputReadError(erlang.GetLineError)
  IntConversionError
}

fn to_int(s) {
  int.parse(s)
  |> result.map_error(fn(_) { IntConversionError })
}

fn read_input() {
  erlang.get_line("Guess a number between 0 and 100: ")
  |> result.map_error(InputReadError)
}

pub fn main() {
  run(Game(secret: int.random(100), guess_count: 0))
}
