#include <stdio.h>
#include <stdlib.h>

#include "bmp.h"

int main(int argc, char *argv[])
{
    // ensure proper usage
    if (argc != 4)
    {
        fprintf(stderr, "Usage: ./resize n infile outfile\n");
        return 1;
    }

    // remember filenames
    int n = strtol(argv[1], NULL, 10);
    char *infile = argv[2];
    char *outfile = argv[3];

    // open input file
    FILE *inptr = fopen(infile, "rb");
    if (inptr == NULL)
    {
        fprintf(stderr, "Could not open %s.\n", infile);
        return 2;
    }

    // open output file
    FILE *outptr = fopen(outfile, "wb+");
    if (outptr == NULL)
    {
        fclose(inptr);
        fprintf(stderr, "Could not create %s.\n", outfile);
        return 3;
    }

    // read infile's BITMAPFILEHEADER
    BITMAPFILEHEADER bf;
    fread(&bf, sizeof(BITMAPFILEHEADER), 1, inptr);

    // read infile's BITMAPINFOHEADER
    BITMAPINFOHEADER bi;
    fread(&bi, sizeof(BITMAPINFOHEADER), 1, inptr);

    // ensure infile is (likely) a 24-bit uncompressed BMP 4.0
    if (bf.bfType != 0x4d42 || bf.bfOffBits != 54 || bi.biSize != 40 ||
        bi.biBitCount != 24 || bi.biCompression != 0)
    {
        fclose(outptr);
        fclose(inptr);
        fprintf(stderr, "Unsupported file format.\n");
        return 4;
    }

    // determine padding for scanlines
    int padding_before = (4 - (bi.biWidth * sizeof(RGBTRIPLE)) % 4) % 4;
    int padding_after = (4 - (bi.biWidth * n * sizeof(RGBTRIPLE)) % 4) % 4;

    // keep original value
    int width_orig = bi.biWidth;
    int height_orig = bi.biHeight;

    // scale
    bi.biWidth *= n;
    bi.biHeight *= n;
    bi.biSizeImage = (bi.biWidth * sizeof(RGBTRIPLE) + padding_after) * abs(bi.biHeight);
    bf.bfSize = 54 + bi.biSizeImage;

    // write outfile's BITMAPFILEHEADER
    fwrite(&bf, sizeof(BITMAPFILEHEADER), 1, outptr);

    // write outfile's BITMAPINFOHEADER
    fwrite(&bi, sizeof(BITMAPINFOHEADER), 1, outptr);

    // iterate over infile's scanlines
    for (int i = 0, biHeight = abs(height_orig); i < biHeight; i++)
    {
        // iterate over pixels in scanline
        for (int j = 0; j < width_orig; j++)
        {
            // temporary storage
            RGBTRIPLE triple;

            // read RGB triple from infile
            fread(&triple, sizeof(RGBTRIPLE), 1, inptr);

            for (int k = 0; k < n; k++)
            {
                // write RGB triple to outfile
                fwrite(&triple, sizeof(RGBTRIPLE), 1, outptr);
            }
        }

        // skip over padding, if any
        fseek(inptr, padding_before, SEEK_CUR);

        // then add it back (to demonstrate how)
        for (int j = 0; j < padding_after; j++)
        {
            fputc(0x00, outptr);
        }

        // dump same low
        int low_size = bi.biWidth * 3 + padding_after;
        char *low = malloc(low_size);
        if (low == NULL)
        {
            fclose(outptr);
            fclose(inptr);
            fprintf(stderr, "Fail to allocate memory.\n");
            return 5;
        }
        fflush(outptr);
        fseek(outptr, -low_size, SEEK_CUR);
        fread(low, low_size, 1, outptr);

        for (int j = 0; j < n - 1; j++)
        {
            fwrite(low, low_size, 1, outptr);
        }
        free(low);
    }

    // close infile
    fclose(inptr);

    // close outfile
    fclose(outptr);

    // success
    return 0;
}
