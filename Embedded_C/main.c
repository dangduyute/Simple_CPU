#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define SERIAL_PORT "/dev/ttyUSB2"
#define BAUDRATE    B115200

// Opcode (giữ nguyên)
#define OP_NOP      0
#define OP_ADD      1
#define OP_SUB      2
#define OP_MUL      3
#define OP_AND      4
#define OP_OR       5
#define OP_NOT      6
#define OP_XOR      7

int fd;

//------------------------------------------
// Cấu hình UART
//------------------------------------------
static int setup_serial(const char *device) {
    int fd = open(device, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    struct termios options;
    tcgetattr(fd, &options);
    options.c_cflag = BAUDRATE | CS8 | CLOCAL | CREAD;
    options.c_iflag = IGNPAR;
    options.c_oflag = 0;
    options.c_lflag = 0;
    tcflush(fd, TCIFLUSH);
    tcsetattr(fd, TCSANOW, &options);
    return fd;
}

//------------------------------------------
// In nhị phân 16-bit
//------------------------------------------
void print_binary16(uint16_t val) {
    for (int i = 15; i >= 0; i--) {
        printf("%d", (val >> i) & 1);
    }
}

//------------------------------------------
// Gửi khung lệnh: Opcode + A + B (int16)
//------------------------------------------
int ASM(uint8_t opcode, int16_t a, int16_t b) {
    uint16_t ua = (uint16_t)a;
    uint16_t ub = (uint16_t)b;

    uint8_t a_hi = (ua >> 8) & 0xFF;
    uint8_t a_lo = ua & 0xFF;

    uint8_t b_hi = (ub >> 8) & 0xFF;
    uint8_t b_lo = ub & 0xFF;

    // Gửi lần lượt Opcode, A_hi, A_lo, B_hi, B_lo
    uint8_t txbuf[5] = { opcode, a_hi, a_lo, b_hi, b_lo };

    ssize_t n = write(fd, txbuf, 5);
    if (n != 5) {
        perror("write");
        return -1;
    }
    return 0;   // thành công
}

int main(void) {
    uint8_t opcode;
    int a, b;          // dùng int để scanf, sau đó check range rồi cast sang int16_t
    int ret;

    fd = setup_serial(SERIAL_PORT);
    if (fd < 0) {
        return 1;
    }

    while (1) {
        printf("Enter Opcode (0..7): ");
        if (scanf("%hhd", &opcode) != 1) {
            printf("Invalid opcode input\n");
            return 1;
        }

        if (opcode > OP_XOR) {
            fprintf(stderr, "Error: Opcode must be between %d and %d\n", OP_NOP, OP_XOR);
            return 1;
        }

        printf("Enter a (-255 to 255): ");
        if (scanf("%d", &a) != 1) {
            printf("Invalid a\n");
            return 1;
        }

        printf("Enter b (-255 to 255): ");
        if (scanf("%d", &b) != 1) {
            printf("Invalid b\n");
            return 1;
        }

        if (a < -255 || a > 255 || b < -255 || b > 255) {
            fprintf(stderr, "Error: a, b must be between -255 and 255\n");
            return 1;
        }

        int16_t a_s = (int16_t)a;
        int16_t b_s = (int16_t)b;

        printf("\nOpcode: %d\n", opcode);

        printf("\nEncoded integer values (16-bit two's complement):\n");
        printf("a = %d -> 0x%04X -> ", a_s, (uint16_t)a_s);
        print_binary16((uint16_t)a_s);
        printf("\n");

        printf("b = %d -> 0x%04X -> ", b_s, (uint16_t)b_s);
        print_binary16((uint16_t)b_s);
        printf("\n");

        // Gửi qua UART
        ret = ASM(opcode, a_s, b_s);
        if (ret == 0)
            printf("\nSuccess: Sent 5 bytes via UART (Opcode, A_hi, A_lo, B_hi, B_lo)...\n");
        else {
            printf("\nFailed to send via UART\n");
            close(fd);
            return 1;
        }

        // Nhận lại C_hi và C_lo
        uint8_t c_hi, c_lo;
        if (read(fd, &c_hi, 1) != 1) {
            perror("read c_hi");
            close(fd);
            return 1;
        }
        if (read(fd, &c_lo, 1) != 1) {
            perror("read c_lo");
            close(fd);
            return 1;
        }

        uint16_t c_u = ((uint16_t)c_hi << 8) | c_lo;
        int16_t  c_s = (int16_t)c_u;   // sign-extend

        printf("\nReceived C (16-bit):\n");
        printf("c = %d -> 0x%04X -> ", c_s, c_u);
        print_binary16(c_u);
        printf("\n\n");
    }

    close(fd);
    return 0;
}
