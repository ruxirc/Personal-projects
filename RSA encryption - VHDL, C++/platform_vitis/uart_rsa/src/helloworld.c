#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"

int main() {
    // Declaratii pentru GPIO
    XGpio inputRX, inputOperationMode;    // RX și OperationMode
    XGpio outputTX;  // Ieșire TX
    XGpio inputSwitch, inputButon, outputLed;

    // Variabile pentru date
    int rx;
    int operationMode;  // 0 pentru criptare, 1 pentru decriptare
    int switch_data = 0;
    int button_data = 0;
    int tx = 0;

    // Inițializare GPIO pentru switch-uri, LED-uri, butoane, RX, TX și mode
    XGpio_Initialize(&inputRX, XPAR_AXI_GPIO_RX_BASEADDR);
    XGpio_Initialize(&inputOperationMode, XPAR_AXI_GPIO_OPMODE_BASEADDR);
    XGpio_Initialize(&outputTX, XPAR_AXI_GPIO_TX_BASEADDR);
    XGpio_Initialize(&inputSwitch, XPAR_AXI_GPIO_SWS_BASEADDR);
    XGpio_Initialize(&inputButon, XPAR_AXI_GPIO_BTNS_BASEADDR);
    XGpio_Initialize(&outputLed, XPAR_AXI_GPIO_LEDS_BASEADDR);

    // Setare direcție GPIO
    XGpio_SetDataDirection(&inputRX, 1, 0xF);  // RX: intrare
    XGpio_SetDataDirection(&inputOperationMode, 1, 0x0);  // OperationMode: ieșire
    XGpio_SetDataDirection(&outputTX, 1, 0x0);  // TX: ieșire
    XGpio_SetDataDirection(&inputSwitch, 1, 0xF);  // Switch: intrare
    XGpio_SetDataDirection(&inputButon, 1, 0xF);  // Buton: intrare
    XGpio_SetDataDirection(&outputLed, 1, 0x0);  // LED-uri: ieșire

    // Inițializare platformă
    init_platform();
    xil_printf("Sistem UART și GPIO este gata.\n");

    while (1) {
        // Citește datele de la RX, operationMode, switch-uri și butoane
        button_data = XGpio_DiscreteRead(&inputButon, 1);  // Citește valoarea butonului
        switch_data = XGpio_DiscreteRead(&inputSwitch, 1);  // Citește datele de la switch-uri

        // Gestionează apăsarea butoanelor pentru a selecta opMode
        if (button_data == 0b00001) {
            // Butonul 1: Setează operationMode la 0 (criptare)
            operationMode = 0; 
            xil_printf("Modul de criptare activat.\n");
        } 
        else if (button_data == 0b00010) {
            // Butonul 2: Setează operationMode la 1 (decriptare)
            operationMode = 1;
            xil_printf("Modul de decriptare activat.\n");
        }

        // Trimite switch_data prin RX (la modul)
        xil_printf("Trimit datele de la switch-uri: %d\n", switch_data);

        for (int i = 0; i < 4; i++) {
            tx = (switch_data >> i) & 1;  // Extrage bitul i din switch_data
            XGpio_DiscreteWrite(&outputTX, 1, tx);  // Trimite bitul prin TX
            xil_printf("Bitul %d trimis: %d\n", i, tx);
        }

        // Așteaptă să primească date de la modul prin RX
        xil_printf("Aștept date de la modul prin RX...\n");

        int received_data = 0;
        for (int i = 0; i < 4; i++) {
            // Citește bit cu bit de la RX
            rx = XGpio_DiscreteRead(&inputRX, 1);
            received_data |= (rx << i);  // Reconstituie valoarea datelor
            xil_printf("Bitul %d primit: %d\n", i, rx);
        }

        // Afișează datele primite pe LED-uri
        xil_printf("Date primite de la modul: %d\n", received_data);
        XGpio_DiscreteWrite(&outputLed, 1, received_data);  // Scrie datele pe LED-uri
        xil_printf("Date afișate pe LED-uri: %d\n", received_data);

        // Întârziere pentru stabilitate
        usleep(200000);
    }

    // Finalizare
    cleanup_platform();
    return 0;
}
