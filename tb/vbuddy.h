#ifndef VBD_H
#define VBD_H

int vbdOpen();
void vbdClose();
void vbdBar(int val);
void vbdCycle(int cycle);
int vbdFlag();
void vbdSetMode(int mode);
void vbdHex(int position, int value);
void vbdPlot(int x, int y, int style);
void vbdHeader(const char* header);
int vbdGetkey(); 

#endif // VBD_H
