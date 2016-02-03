using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using System.IO;
using System.IO.Ports;

namespace arduinoControl
{
    public partial class Form1 : Form
    {
        // objeto de escrita 
        StreamWriter write = null;

        // leituras do sensores
        double[] sensores = {0,0,0};
        
        public Form1()
        {
            InitializeComponent();

            // lista as portas COM do sistema
            portasCOM();

            // configura o timer
            timerLeitura.Interval = 3000;
            timerLeitura.Enabled = false;
        }

        // botão conectar
        private void butConectar_Click(object sender, EventArgs e)
        {
            // tenta conectar com o arduino
            try
            {
                // verifica o estado da combobox
                if (cBoxNomes.Text == "")
                {
                    MessageBox.Show("Selecione a porta COM do Arduino!");
                }
                else
                {
                    // seleciona a porta COM
                    serialPort.PortName = cBoxNomes.Text;

                    // seleciona a velocidade da comunicação
                    serialPort.BaudRate = 9600;

                    // configura a paridade de bits
                    serialPort.Parity = Parity.None;

                    // configura o número de bits
                    serialPort.DataBits = 8;

                    // bit de parada
                    serialPort.StopBits = StopBits.One;

                    // tenta abrir a porta serial
                    try
                    {
                        // abre a porta
                        serialPort.Open();

                        // aviso de conexão bem sucedida
                        MessageBox.Show("Dispositivo conectado!");

                        // ajusta a interface
                        butConectar.Enabled = false;
                        butDesconectar.Enabled = true;

                        // obtém o nome do arquivo a ser gravado
                        string nome = DateTime.Now.ToLongDateString();

                        // cria objeto de escrita
                        write = new StreamWriter(nome + ".txt", true);

                        // liga o timer de leitura
                        timerLeitura.Enabled = true;
                    }
                    catch (System.IO.IOException)
                    {
                        // aviso de porta COM já sendo utilizada
                        MessageBox.Show("Acesso negado! \nA porta COM não existe ou está sendo utilizada por outro aplicativo.");
                    }
                }
            }
            catch (UnauthorizedAccessException)
            {
                // aviso de porta COM já sendo utilizada
                MessageBox.Show("Acesso negado! \nA porta COM não existe ou está sendo utilizada por outro aplicativo.");
            }
        }

        // botão desconectar
        private void butDesconectar_Click(object sender, EventArgs e)
        {
            // desliga o timer de leitura
            timerLeitura.Enabled = false;

            // fecha a porta serial
            serialPort.Close();

            // aviso de conexão bem sucedida
            MessageBox.Show("Dispositivo desconectado!");
            
            // encerra o objeto de escrita
            write.Close();

            // ajusta a interface
            butConectar.Enabled = true;
            butDesconectar.Enabled = false;
        }

        // rotina que determina as portas COM do sistema
        void portasCOM()
        {
            /* // obtém as portas disponíveis
            string[] portas = SerialPort.GetPortNames(); */

            // gera uma lista das portas seriais
            string[] portas = {"COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "COM10"};
            
            // adiciona os nomes das portas no combobox
            cBoxNomes.Items.AddRange(portas);
   
            // seleciona porta default
            cBoxNomes.SelectedItem = "COM3";
        }

        // realiza a leitura DAVIS
        void leDavis()
        {
            // solicita a leitura da tensão no Arduino
            serialPort.WriteLine("0");
            
            // tenta realizar a leitura da tensão
            try
            {
                // le a porta serial
                string tensao = serialPort.ReadLine();

                // determina o valor real da tensão
                double tensaoAjustada = Convert.ToDouble(tensao)/1000.0;

                // salva a tensão
                sensores[0] = tensaoAjustada;
            }
            catch (TimeoutException)
            {
                // aviso de conexão expirada
                MessageBox.Show("Tempo limite excedido!");
            }
        }

        // realiza a leitura TRANSISTOR
        void leTransistor()
        {
            // solicita a leitura da tensão no Arduino
            serialPort.WriteLine("1");

            // tenta realizar a leitura da tensão
            try
            {
                // le a porta serial
                string tensao = serialPort.ReadLine();

                // determina o valor real da tensão
                double tensaoAjustada = Convert.ToDouble(tensao) / 1000.0;

                // salva a tensão
                sensores[1] = tensaoAjustada;
            }
            catch (TimeoutException)
            {
                // aviso de conexão expirada
                MessageBox.Show("Tempo limite excedido!");
            }
        }

        // realiza a leitura MÓDULO
        void leModulo()
        {
            // solicita a leitura da tensão no Arduino
            serialPort.WriteLine("2");

            // tenta realizar a leitura da tensão
            try
            {
                // le a porta serial
                string tensao = serialPort.ReadLine();

                // determina o valor real da tensão
                double tensaoAjustada = Convert.ToDouble(tensao) / 1000.0;

                // salva a tensão
                sensores[2] = tensaoAjustada;
            }
            catch (TimeoutException)
            {
                // aviso de conexão expirada
                MessageBox.Show("Tempo limite excedido!");
            }
        }

        // rotina chamada a cada estouro do timer
        private void timerLeitura_Tick(object sender, EventArgs e)
        {
            // registra o instante da leitura em uma string
            string horario = DateTime.Now.ToLongTimeString();
            
            // realiza a leitura das grandezas dos sensores
            leDavis();
            leTransistor();
            leModulo();

            // salva o valor da tensão no log
            write.WriteLine(horario + "\t" + sensores[0] + "\t" + sensores[1] + "\t" + sensores[2] + "\n");
        }
    }
}
