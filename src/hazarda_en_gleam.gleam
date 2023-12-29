import gleam/io
import gleam/erlang
import gleam/int
import gleam/result
import gleam/string

pub type Game {
  Game(secret: Int, guess_count: Int)
}

fn run(game: Game) {
  case
    read_input()
    |> result.map(string.trim)
    |> result.try(to_int)
  {
    Ok(guess) if guess == game.secret -> io.println("You got it")
    Ok(guess) if guess > game.secret -> {
      io.println("Try a smaller number")
      run(Game(game.secret, game.guess_count + 1))
    }
    Ok(guess) if guess < game.secret -> {
      io.println("Try a bigger number")
      run(Game(game.secret, game.guess_count + 1))
    }

    Ok(_) -> io.println("unreachable")

    Error(InputReadError(_)) -> {
      io.println("failed to read line")
      run(game)
    }
    Error(IntConversionError) -> {
      io.println("failed to convert to integer")
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
