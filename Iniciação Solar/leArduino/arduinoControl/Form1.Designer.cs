namespace arduinoControl
{
    partial class Form1
    {
        /// <summary>
        /// Variável de designer necessária.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpar os recursos que estão sendo usados.
        /// </summary>
        /// <param name="disposing">verdade se for necessário descartar os recursos gerenciados; caso contrário, falso.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region código gerado pelo Windows Form Designer

        /// <summary>
        /// Método necessário para suporte do Designer - não modifique
        /// o conteúdo deste método com o editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.butConectar = new System.Windows.Forms.Button();
            this.butDesconectar = new System.Windows.Forms.Button();
            this.serialPort = new System.IO.Ports.SerialPort(this.components);
            this.lbTensao = new System.Windows.Forms.Label();
            this.tBoxTensao = new System.Windows.Forms.TextBox();
            this.lbNomes = new System.Windows.Forms.Label();
            this.cBoxNomes = new System.Windows.Forms.ComboBox();
            this.timerLeitura = new System.Windows.Forms.Timer(this.components);
            this.SuspendLayout();
            // 
            // butConectar
            // 
            this.butConectar.Location = new System.Drawing.Point(12, 12);
            this.butConectar.Name = "butConectar";
            this.butConectar.Size = new System.Drawing.Size(89, 29);
            this.butConectar.TabIndex = 0;
            this.butConectar.Text = "Conectar";
            this.butConectar.UseVisualStyleBackColor = true;
            this.butConectar.Click += new System.EventHandler(this.butConectar_Click);
            // 
            // butDesconectar
            // 
            this.butDesconectar.Location = new System.Drawing.Point(12, 47);
            this.butDesconectar.Name = "butDesconectar";
            this.butDesconectar.Size = new System.Drawing.Size(89, 29);
            this.butDesconectar.TabIndex = 1;
            this.butDesconectar.Text = "Desconectar";
            this.butDesconectar.UseVisualStyleBackColor = true;
            this.butDesconectar.Click += new System.EventHandler(this.butDesconectar_Click);
            // 
            // serialPort
            // 
            this.serialPort.PortName = "COM3";
            // 
            // lbTensao
            // 
            this.lbTensao.AutoSize = true;
            this.lbTensao.Location = new System.Drawing.Point(125, 63);
            this.lbTensao.Name = "lbTensao";
            this.lbTensao.Size = new System.Drawing.Size(43, 13);
            this.lbTensao.TabIndex = 2;
            this.lbTensao.Text = "Tensão";
            // 
            // tBoxTensao
            // 
            this.tBoxTensao.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tBoxTensao.ForeColor = System.Drawing.SystemColors.WindowText;
            this.tBoxTensao.Location = new System.Drawing.Point(128, 79);
            this.tBoxTensao.Name = "tBoxTensao";
            this.tBoxTensao.ReadOnly = true;
            this.tBoxTensao.Size = new System.Drawing.Size(100, 21);
            this.tBoxTensao.TabIndex = 3;
            this.tBoxTensao.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // lbNomes
            // 
            this.lbNomes.AutoSize = true;
            this.lbNomes.Location = new System.Drawing.Point(125, 12);
            this.lbNomes.Name = "lbNomes";
            this.lbNomes.Size = new System.Drawing.Size(64, 13);
            this.lbNomes.TabIndex = 4;
            this.lbNomes.Text = "Portas COM";
            // 
            // cBoxNomes
            // 
            this.cBoxNomes.FormattingEnabled = true;
            this.cBoxNomes.Location = new System.Drawing.Point(128, 28);
            this.cBoxNomes.Name = "cBoxNomes";
            this.cBoxNomes.Size = new System.Drawing.Size(121, 21);
            this.cBoxNomes.TabIndex = 5;
            // 
            // timerLeitura
            // 
            this.timerLeitura.Interval = 1000;
            this.timerLeitura.Tick += new System.EventHandler(this.timerLeitura_Tick);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(259, 115);
            this.Controls.Add(this.cBoxNomes);
            this.Controls.Add(this.lbNomes);
            this.Controls.Add(this.tBoxTensao);
            this.Controls.Add(this.lbTensao);
            this.Controls.Add(this.butDesconectar);
            this.Controls.Add(this.butConectar);
            this.Name = "Form1";
            this.Text = "arduinoControl";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button butConectar;
        private System.Windows.Forms.Button butDesconectar;
        private System.IO.Ports.SerialPort serialPort;
        private System.Windows.Forms.Label lbTensao;
        private System.Windows.Forms.TextBox tBoxTensao;
        private System.Windows.Forms.Label lbNomes;
        private System.Windows.Forms.ComboBox cBoxNomes;
        private System.Windows.Forms.Timer timerLeitura;
    }
}

