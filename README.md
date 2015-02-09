#Text Rain Homework Assignment for Interactive Graphics COMP 394-01
##Guillermo Vera and Asra Nizami

Guillermo developed the algorithm for generating pseudo-random characters. The program currently reads from a text file and breaks up the text into lines. It then picks characters from each line, and only picks characters from the next line after the first one is exhausted. This way, there is a higher probability of words from each line appearing on the screen. 

The velocity with which the characters fall is the same as in the physical world. The letters start falling from rest, and then accelerate with the general forumla (s = ut + 0.5a(t^2)). The letters stop when there is an object below them, and when that object is raised, the letters rise with them. When the object is removed from beneath the letter, the letter once again starts falling from rest and accelerates due to "gravity".

## Available commands of our implementation:
* **Spacebar:** toggle debugging mode
* **Up/Down arrow keys:** Move threshold up or down
* **L, A, G:** Change the black/white conversion method:
 * L (default): luminosity
 * A: average
 * G: lightness
* **S:** Toggle image smoothing
