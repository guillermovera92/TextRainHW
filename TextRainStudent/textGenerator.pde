import java.util.Random;
import java.io.FileReader;
import java.io.FileNotFoundException;

class TextGenerator {

  String currentLine;  
  String letter;
  int randPos;
  String path;

  BufferedReader reader;
  Random rand = new Random();

  TextGenerator(String path) {
    this.path = path;
    reader = createReader(path);
  }

  String getNextLetter() {
    if (currentLine == null || currentLine.length() == 0) {
      try {
        currentLine = reader.readLine().replaceAll("[^a-zA-Z]", "").toUpperCase();
        if (currentLine == null) {
          reader = createReader(path);
        }
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
    } 
    randPos = rand.nextInt(currentLine.length());
    letter = currentLine.charAt(randPos) + "";
    currentLine = currentLine.substring(0, randPos) + currentLine.substring(randPos + 1);
    return letter;
  }
}

