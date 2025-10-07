# 📦 Exportador de Licenças Microsoft 365

Uma ferramenta simples para **exportar licenças do Microsoft 365** em um arquivo CSV, separando cada licença por linha. Ideal para auditoria e gestão de usuários.

---

## ⚙️ Requisitos

- Acesso de **Administrador Global** no [Microsoft 365 Admin Center](https://admin.microsoft.com)
- Login inicial será solicitado **apenas uma vez**. Depois, não será necessário autenticar novamente.

---

## 🚀 Funcionalidades

- Exporta todas as licenças atribuídas a usuários.
- Gera um arquivo **CSV** com cada licença em uma linha.
- Facilita a gestão e auditoria das licenças da organização.

---

## 📄 Exemplo de saída

Arquivo gerado: `licencas.csv`

| Usuário            | Licença             | Status |
|-------------------|-------------------|--------|
| usuario@empresa.com | Microsoft 365 E3   | Ativa  |
| usuario2@empresa.com| Power BI Pro       | Inativa|

---

## 💡 Observações

- As credenciais são armazenadas de forma segura após o primeiro login.
- Não é necessário autenticar novamente nas próximas execuções.

---

