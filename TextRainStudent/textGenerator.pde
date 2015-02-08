import java.util.Random;
import java.io.FileReader;
import java.io.FileNotFoundException;

class TextGenerator {

  String currentLine;  
  String letter;
  int randPos;

  BufferedReader reader;
  Random rand = new Random();

  TextGenerator(String path) {
      reader = createReader(path);
  }

  String getNextLetter() {
    if (currentLine == null) {
      try {
        currentLine = reader.readLine().replaceAll("[^a-zA-Z]", "").toUpperCase();
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
    }
    if (currentLine != null) {
      randPos = rand.nextInt(1);//currentLine.length());
      letter = currentLine.substring(randPos, randPos + 1);
      currentLine = currentLine.substring(0, randPos) + currentLine.substring(randPos + 1);
    }
    return letter;
  }
}

