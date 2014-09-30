#include<stdio.h>
#include<stdlib.h>
#include<string.h>

void fprintsignature(FILE *fp,  const char *chars)
{
  int i;
  for (i=0; i<' '; i++)
    if (chars[i]) fprintf(fp,  "\\x%02x", i);
  for (; i<'0'; i++)
    if (chars[i]) fprintf(fp,  "%c", i);
  for (; i<='9'; i++) {
    if (chars[i]) {
      fprintf(fp, "[:digit:]");
      break;
    }
  }
  for (i='9'+1; i<'A'; i++)
    if (chars[i]) fprintf(fp, "%c", i);
  for (; i<='Z'; i++) {
    if (chars[i]) {
      fprintf(fp, "[:upper:]");
      break;
    }
  }
  for (i='Z'+1; i<'a'; i++)
    if (chars[i]) fprintf(fp, "%c", i);
  for (; i<='z'; i++) {
    if (chars[i]) {
      fprintf(fp, "[:lower:]");
      break;
    }
  }
  for (i='z'+1; i<0x7f; i++)
    if (chars[i]) fprintf(fp, "%c", i);
  for (; i<=0xff; i++)
    if (chars[i]) fprintf(fp, "\\x%02x", i);
}

int
main(int argc, char **argv)
{
  char buf[1024];
  char chars[256];
  int c;
  int ln = 0;
  size_t len;
  FILE *fp = stdin;

  memset(chars, 0, sizeof(chars));

  while (!feof(fp)) {
    len = fread(buf, 1, sizeof(buf), fp);
    if (len > 0) {
      int i;
      for (i=0; i<len; i++) {
        int c = buf[i];
        chars[c & 0xff] = 1;
        if ((ln % 10000) == 0) {
          fputs("\r", stderr);
          fprintf(stderr, "%d: ", ln);
          fprintsignature(stderr, chars);
          fflush(stderr);
        }

        ln++;
      }
    }
  }

  fputs("\n", stderr);
  fprintsignature(stdout, chars);
  puts("\n");

  return 0;
}
  
