# 🚀 Instalador Automatizado para Sistemas e Softwares Corporativos

Este script em **PowerShell** automatiza a instalação de diversos sistemas, softwares e drivers utilizados em ambientes corporativos. Ele inclui downloads, configurações, instalação silenciosa e criação de atalhos, tudo em um menu interativo.

É possivel transformar em executavel, basta transformar o arquivo .ps1 em exe. (Inclusive é a maneira que utilizo na empresa)

---

## ⚙️ Funcionalidades

O instalador permite:

### Sistemas Corporativos
- **SAP** – Download, instalação e configuração.
- **Protheus Antigo** – Download, extração e criação de atalho para o SmartClient.

### Pacotes Office e Segurança
- **Microsoft Office**
- **Adobe Acrobat Reader**
- **Kaspersky Endpoint Security**

### Utilitários
- **AnyDesk** – Instalação automática ou apenas download.
- **WinRAR**

### Drivers de Impressora
- **Impressora M320F**
- **Impressora Zebra ZT230**

---

## 📝 Detalhes

- Cria uma pasta temporária para downloads e extração:  

- Valida arquivos baixados antes da instalação (verifica tamanho mínimo).
- Instalação silenciosa quando disponível.
- Geração automática de atalhos (ex: SmartClient Protheus antigo).
- Menu interativo para escolher quais softwares instalar.

---

## 💻 Como Usar

1. Abra o **PowerShell como Administrador**.
2. Execute o script:
3. Escolha a opção desejada no menu

Aguarde a conclusão da instalação. Alguns softwares podem solicitar reinicialização.

---

## ⚠️ Observações

Verifique permissões administrativas e espaço em disco.
O script realiza download de arquivos grandes; aguarde a conclusão sem interromper.

---

## 📂 Estrutura do Script
$tempPath – Pasta temporária para downloads e extração.

Instalar-SAP, Configurar-SAP – Instalação e configuração do SAP.

Instalar-Office, Instalar-AdobeAcrobat, Instalar-Kaspersky – Instalação de softwares corporativos.

Instalar-AnyDesk, Instalar-WinRAR – Instalação de utilitários.

Instalar-DriverM320F, Instalar-DriverZebraZT230 – Instalação de drivers de impressora.

Instalar-ProtheusAntigo – Download, extração e criação de atalho.

Menu – Menu interativo principal do script.
