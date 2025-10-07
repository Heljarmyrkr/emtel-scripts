# Caminho temporário para downloads e extracao
$tempPath = "$env:TEMP\NomedaEmpresaInstall"

# Cria pasta temporaria se nao existir
if (-not (Test-Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
}

function Instalar-SAP {
    Write-Host "Instalando SAP..." -ForegroundColor Yellow

    $urlSAP = "Colocar link  do provedor de download aqui"
    $zipSAP = "$tempPath\WIN32.zip"

    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    Invoke-WebRequest -Uri $urlSAP -Headers $headers -OutFile $zipSAP -MaximumRedirection 5

    $info = Get-Item $zipSAP
    if ($info.Length -lt 102400) {
        Write-Host "Erro: arquivo SAP baixado e muito pequeno, provavelmente invalido." -ForegroundColor Red
        return
    }

    try {
        Expand-Archive -Path $zipSAP -DestinationPath $tempPath -Force
    } catch {
        Write-Host "Erro ao descompactar SAP. Arquivo pode estar corrompido." -ForegroundColor Red
        return
    }

    $sapInstaller = Join-Path $tempPath "WIN32\SapGuiSetup.exe"
    if (Test-Path $sapInstaller) {
        Start-Process -FilePath $sapInstaller -Wait
        Write-Host "SAP instalado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "Erro: Instalador SAP nao encontrado." -ForegroundColor Red
    }
}

function Configurar-SAP {
    Write-Host "Configurando SAP..." -ForegroundColor Yellow

    $configTempPath = "$tempPath\SAPConfig"
    if (-not (Test-Path $configTempPath)) {
        New-Item -ItemType Directory -Path $configTempPath | Out-Null
    }

    $arquivos = @(
        @{ Nome = "saplogon.ini";     Url = "Colocar link  do provedor de download aqui"; Destino = "$env:APPDATA\SAP\Common" },
        @{ Nome = "SapLogonTree.xml"; Url = "Colocar link  do provedor de download aqui"; Destino = "$env:APPDATA\SAP\Common" },
        @{ Nome = "hosts";            Url = "Colocar link  do provedor de download aqui"; Destino = "C:\Windows\System32\drivers\etc" },
        @{ Nome = "services";         Url = "Colocar link  do provedor de download aqui"; Destino = "C:\Windows\System32\drivers\etc" }
    )

    foreach ($arq in $arquivos) {
        $tempFile = Join-Path $configTempPath $arq.Nome
        Write-Host "Baixando $($arq.Nome)..."
        try {
            Invoke-WebRequest -Uri $arq.Url -OutFile $tempFile -UseBasicParsing
        } catch {
            Write-Host "Erro ao baixar $($arq.Nome)" -ForegroundColor Red
            continue
        }

        if (-not (Test-Path $arq.Destino)) {
            try {
                New-Item -ItemType Directory -Path $arq.Destino -Force | Out-Null
            } catch {
                Write-Host "Erro ao criar pasta de destino: $($arq.Destino)" -ForegroundColor Red
                continue
            }
        }

        try {
            Copy-Item -Path $tempFile -Destination (Join-Path $arq.Destino $arq.Nome) -Force
            Write-Host "$($arq.Nome) copiado para $($arq.Destino)" -ForegroundColor Green
        } catch {
            Write-Host "Erro ao copiar $($arq.Nome)" -ForegroundColor Red
        }
    }

    Write-Host "Configuracao do SAP concluida!" -ForegroundColor Cyan
}

function Instalar-Office {
    Write-Host "Instalando Microsoft Office..." -ForegroundColor Yellow

    $urlOffice = "Colocar link  do provedor de download aqui"
    $officeInstaller = "$tempPath\OfficeSetup.exe"

    Write-Host "Baixando instalador do Office..."
    $headers = @{ 
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        "Accept" = "*/*"
    }
    
    try {
        # Remove arquivo anterior se existir
        if (Test-Path $officeInstaller) {
            Remove-Item $officeInstaller -Force
        }
        
        Write-Host "Iniciando download do Office..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $urlOffice -Headers $headers -OutFile $officeInstaller -UseBasicParsing -MaximumRedirection 10
        Write-Host "Download concluido." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o instalador do Office: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tentando download alternativo..." -ForegroundColor Yellow
        
        try {
            # Tentativa alternativa sem headers customizados
            Invoke-WebRequest -Uri $urlOffice -OutFile $officeInstaller -UseBasicParsing
        } catch {
            Write-Host "Falha no download alternativo. Verifique a conexao e tente novamente." -ForegroundColor Red
            return
        }
    }

    if (-not (Test-Path $officeInstaller)) {
        Write-Host "Erro: Arquivo do Office nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $officeInstaller
    Write-Host "Tamanho do arquivo baixado: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan
    
    if ($info.Length -lt 10240) {
        Write-Host "Erro: arquivo Office baixado e muito pequeno, provavelmente invalido." -ForegroundColor Red
        Write-Host "Arquivo salvo em: $officeInstaller" -ForegroundColor Gray
        return
    }

    Write-Host "Executando instalador do Office..." -ForegroundColor Yellow
    Write-Host "ATENCAO: A instalacao do Office pode demorar alguns minutos. Aguarde..." -ForegroundColor Cyan
    
    try {
        # Tenta executar com caminho entre aspas para evitar problemas com espacos
        Start-Process -FilePath "`"$officeInstaller`"" -Wait -WindowStyle Normal
        Write-Host "Microsoft Office instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro durante a execucao do instalador do Office: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tente executar manualmente o arquivo: $officeInstaller" -ForegroundColor Yellow
    }
}

function Instalar-AdobeAcrobat {
    Write-Host "Instalando Adobe Acrobat Reader..." -ForegroundColor Yellow

    $urlAdobe = "Colocar link  do provedor de download aqui"
    $adobeInstaller = "$tempPath\AdobeReaderSetup.exe"

    Write-Host "Baixando instalador do Adobe Acrobat Reader..."
    $headers = @{ 
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        "Accept" = "*/*"
    }
    
    try {
        # Remove arquivo anterior se existir
        if (Test-Path $adobeInstaller) {
            Remove-Item $adobeInstaller -Force
        }
        
        Write-Host "Iniciando download do Adobe Acrobat Reader..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $urlAdobe -Headers $headers -OutFile $adobeInstaller -UseBasicParsing -MaximumRedirection 10
        Write-Host "Download concluido." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o instalador do Adobe Acrobat Reader: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tentando download alternativo..." -ForegroundColor Yellow
        
        try {
            # Tentativa alternativa sem headers customizados
            Invoke-WebRequest -Uri $urlAdobe -OutFile $adobeInstaller -UseBasicParsing
        } catch {
            Write-Host "Falha no download alternativo. Verifique a conexao e tente novamente." -ForegroundColor Red
            return
        }
    }

    if (-not (Test-Path $adobeInstaller)) {
        Write-Host "Erro: Arquivo do Adobe Acrobat Reader nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $adobeInstaller
    Write-Host "Tamanho do arquivo baixado: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan
    
    if ($info.Length -lt 102400) {
        Write-Host "Erro: arquivo Adobe Acrobat Reader baixado e muito pequeno, provavelmente invalido." -ForegroundColor Red
        Write-Host "Arquivo salvo em: $adobeInstaller" -ForegroundColor Gray
        return
    }

    Write-Host "Executando instalador do Adobe Acrobat Reader..." -ForegroundColor Yellow
    Write-Host "ATENCAO: A instalacao pode demorar alguns minutos. Aguarde..." -ForegroundColor Cyan
    
    try {
        # Tenta executar com parametros para instalacao silenciosa
        Start-Process -FilePath "`"$adobeInstaller`"" -ArgumentList "/S" -Wait -WindowStyle Normal
        Write-Host "Adobe Acrobat Reader instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro na instalacao silenciosa, tentando instalacao normal..." -ForegroundColor Yellow
        try {
            Start-Process -FilePath "`"$adobeInstaller`"" -Wait -WindowStyle Normal
            Write-Host "Adobe Acrobat Reader instalado com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "Erro durante a execucao do instalador do Adobe Acrobat Reader: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Tente executar manualmente o arquivo: $adobeInstaller" -ForegroundColor Yellow
        }
    }
}

function Instalar-Kaspersky {
    Write-Host "Instalando Kaspersky Endpoint Security..." -ForegroundColor Yellow

    $urlKaspersky = "Colocar link  do provedor de download aqui"
    $kasperskyInstaller = "$tempPath\KasperskySetup.exe"

    Write-Host "Baixando instalador do Kaspersky..."
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    
    try {
        Write-Host "Aguarde, o arquivo do Kaspersky e grande e pode demorar para baixar..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $urlKaspersky -Headers $headers -OutFile $kasperskyInstaller -MaximumRedirection 5
    } catch {
        Write-Host "Erro ao baixar o instalador do Kaspersky." -ForegroundColor Red
        return
    }

    $info = Get-Item $kasperskyInstaller
    if ($info.Length -lt 102400) {
        Write-Host "Erro: arquivo Kaspersky baixado e muito pequeno, provavelmente invalido." -ForegroundColor Red
        return
    }

    if (Test-Path $kasperskyInstaller) {
        Write-Host "Executando instalador do Kaspersky..." -ForegroundColor Yellow
        Write-Host "ATENCAO: A instalacao do Kaspersky pode demorar varios minutos e pode solicitar reinicializacao." -ForegroundColor Cyan
        Write-Host "O instalador pode abrir em modo silencioso. Aguarde a conclusao..." -ForegroundColor Cyan
        
        try {
            # Executa o instalador com parametros para instalacao silenciosa (opcional)
            Start-Process -FilePath $kasperskyInstaller -ArgumentList "/S" -Wait
            Write-Host "Kaspersky Endpoint Security instalado com sucesso." -ForegroundColor Green
            Write-Host "IMPORTANTE: Pode ser necessario reiniciar o computador para ativar completamente o antivirus." -ForegroundColor Yellow
        } catch {
            Write-Host "Erro durante a execucao do instalador do Kaspersky." -ForegroundColor Red
            Write-Host "Tentando executar sem parametros silenciosos..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath $kasperskyInstaller -Wait
                Write-Host "Kaspersky Endpoint Security instalado com sucesso." -ForegroundColor Green
            } catch {
                Write-Host "Erro na instalacaoo do Kaspersky. Execute manualmente o arquivo em: $kasperskyInstaller" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Erro: Instalador do Kaspersky nao encontrado apos o download." -ForegroundColor Red
    }
}

function Instalar-AnyDesk {
    Write-Host "Instalando AnyDesk..." -ForegroundColor Yellow
    Write-Host ""

    # URL do AnyDesk
    $urlAnyDesk = "Colocar link  do provedor de download aqui"
    
    Write-Host "Onde voce deseja salvar o AnyDesk.exe?" -ForegroundColor Cyan
    Write-Host "1 - Desktop (Area de Trabalho)"
    Write-Host "2 - Downloads"
    Write-Host "3 - Pasta temporaria (padrao)"
    Write-Host "4 - Escolher pasta personalizada"
    Write-Host ""
    
    do {
        $opcao = Read-Host "Digite sua opcao (1-4)"
    } while ($opcao -notmatch '^[1-4]$')
    
    switch ($opcao) {
        "1" {
            $destinoPath = [Environment]::GetFolderPath("Desktop")
            $anydeskInstaller = Join-Path $destinoPath "AnyDesk.exe"
            Write-Host "Salvando na Area de Trabalho..." -ForegroundColor Green
        }
        "2" {
            $destinoPath = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
            $anydeskInstaller = Join-Path $destinoPath "AnyDesk.exe"
            Write-Host "Salvando na pasta Downloads..." -ForegroundColor Green
        }
        "3" {
            $destinoPath = $tempPath
            $anydeskInstaller = "$tempPath\AnyDesk.exe"
            Write-Host "Salvando na pasta temporaria..." -ForegroundColor Green
        }
        "4" {
            do {
                $destinoPath = Read-Host "Digite o caminho completo da pasta onde deseja salvar"
                if (-not (Test-Path $destinoPath)) {
                    Write-Host "Pasta nao encontrada. Deseja criar esta pasta? (S/N)" -ForegroundColor Yellow
                    $criarPasta = Read-Host
                    if ($criarPasta -eq "S" -or $criarPasta -eq "s") {
                        try {
                            New-Item -ItemType Directory -Path $destinoPath -Force | Out-Null
                            Write-Host "Pasta criada com sucesso!" -ForegroundColor Green
                            break
                        } catch {
                            Write-Host "Erro ao criar a pasta. Tente novamente." -ForegroundColor Red
                        }
                    } else {
                        Write-Host "Digite um caminho valido ou existente." -ForegroundColor Yellow
                    }
                }
            } while (-not (Test-Path $destinoPath))
            
            $anydeskInstaller = Join-Path $destinoPath "AnyDesk.exe"
            Write-Host "Salvando em: $destinoPath" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "Baixando AnyDesk para: $anydeskInstaller" -ForegroundColor Cyan
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    
    try {
        # Remove arquivo anterior se existir
        if (Test-Path $anydeskInstaller) {
            Write-Host "Arquivo ja existe. Substituindo..." -ForegroundColor Yellow
            Remove-Item $anydeskInstaller -Force
        }
        
        Invoke-WebRequest -Uri $urlAnyDesk -Headers $headers -OutFile $anydeskInstaller -UseBasicParsing -MaximumRedirection 5
        Write-Host "Download do AnyDesk concluido!" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o AnyDesk: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $anydeskInstaller)) {
        Write-Host "Erro: Arquivo do AnyDesk nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $anydeskInstaller
    Write-Host "Tamanho do arquivo: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host "Arquivo salvo em: $anydeskInstaller" -ForegroundColor Green

    if ($info.Length -lt 10240) {
        Write-Host "Erro: arquivo AnyDesk muito pequeno, pode estar invalido." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "O que voce deseja fazer agora?" -ForegroundColor Cyan
    Write-Host "1 - Executar instalacao automaticamente"
    Write-Host "2 - Apenas baixar (executar manualmente depois)"
    Write-Host ""
    
    do {
        $executar = Read-Host "Digite sua opcao (1-2)"
    } while ($executar -notmatch '^[1-2]$')

    if ($executar -eq "1") {
        try {
            Write-Host "Executando instalacao do AnyDesk..." -ForegroundColor Yellow
            Start-Process -FilePath $anydeskInstaller -ArgumentList "--install", "--start-with-win", "--silent" -Wait
            Write-Host "AnyDesk instalado com sucesso!" -ForegroundColor Green
        } catch {
            Write-Host "Erro na instalacao automatica, tentando instalacao manual..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath $anydeskInstaller -Wait
                Write-Host "AnyDesk instalado com sucesso!" -ForegroundColor Green
            } catch {
                Write-Host "Erro na instalacao do AnyDesk." -ForegroundColor Red
                Write-Host "Execute manualmente o arquivo: $anydeskInstaller" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host ""
        Write-Host "Download concluido!" -ForegroundColor Green
        Write-Host "Para instalar o AnyDesk, execute o arquivo: $anydeskInstaller" -ForegroundColor Cyan
        Write-Host ""
        
        # Pergunta se quer abrir a pasta onde foi salvo
        $abrirPasta = Read-Host "Deseja abrir a pasta onde o arquivo foi salvo? (S/N)"
        if ($abrirPasta -eq "S" -or $abrirPasta -eq "s") {
            try {
                Start-Process -FilePath "explorer.exe" -ArgumentList "/select,`"$anydeskInstaller`""
            } catch {
                Write-Host "Nao foi possivel abrir o explorador de arquivos." -ForegroundColor Yellow
            }
        }
    }
}

function Instalar-WinRAR {
    Write-Host "Instalando WinRAR..." -ForegroundColor Yellow

    $urlWinRAR = "Colocar link  do provedor de download aqui"
    $winrarInstaller = "$tempPath\WinRAR-Setup.exe"

    Write-Host "Baixando WinRAR..."
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    
    try {
        Invoke-WebRequest -Uri $urlWinRAR -Headers $headers -OutFile $winrarInstaller -UseBasicParsing -MaximumRedirection 5
        Write-Host "Download do WinRAR concluido." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o WinRAR: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $winrarInstaller)) {
        Write-Host "Erro: Arquivo do WinRAR nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $winrarInstaller
    Write-Host "Tamanho do arquivo: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan

    if ($info.Length -lt 102400) {
        Write-Host "Erro: arquivo WinRAR muito pequeno, pode estar invalido." -ForegroundColor Red
        return
    }

    try {
        Write-Host "Executando instalacao do WinRAR..." -ForegroundColor Yellow
        Start-Process -FilePath $winrarInstaller -ArgumentList "/S" -Wait
        Write-Host "WinRAR instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro na instalacao silenciosa, tentando instalacao normal..." -ForegroundColor Yellow
        try {
            Start-Process -FilePath $winrarInstaller -Wait
            Write-Host "WinRAR instalado com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "Erro na instalacao do WinRAR. Execute manualmente: $winrarInstaller" -ForegroundColor Red
        }
    }
}

function Instalar-DriverM320F {
    Write-Host "Instalando Driver da Impressora M320F..." -ForegroundColor Yellow

    $urlDriver = "Colocar link  do provedor de download aqui"
    $driverInstaller = "$tempPath\DriverM320F.exe"

    Write-Host "Baixando driver da impressora M320F..."
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    
    try {
        Invoke-WebRequest -Uri $urlDriver -Headers $headers -OutFile $driverInstaller -UseBasicParsing -MaximumRedirection 5
        Write-Host "Download do driver M320F concluido." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o driver M320F: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $driverInstaller)) {
        Write-Host "Erro: Arquivo do driver M320F nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $driverInstaller
    Write-Host "Tamanho do arquivo: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan

    if ($info.Length -lt 10240) {
        Write-Host "Erro: arquivo do driver muito pequeno, pode estar invalido." -ForegroundColor Red
        return
    }

    try {
        Write-Host "Executando instalacao do driver M320F..." -ForegroundColor Yellow
        Write-Host "IMPORTANTE: Conecte a impressora M320F antes de continuar a instalacao." -ForegroundColor Cyan
        Start-Process -FilePath $driverInstaller -Wait
        Write-Host "Driver da impressora M320F instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro na instalacao do driver M320F. Execute manualmente: $driverInstaller" -ForegroundColor Red
    }
}

function Instalar-DriverZebraZT230 {
    Write-Host "Instalando Driver da Impressora Zebra ZT230..." -ForegroundColor Yellow

    $urlDriver = "Colocar link  do provedor de download aqui"
    $driverInstaller = "$tempPath\DriverZebraZT230.exe"

    Write-Host "Baixando driver da impressora Zebra ZT230..."
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    
    try {
        Invoke-WebRequest -Uri $urlDriver -Headers $headers -OutFile $driverInstaller -UseBasicParsing -MaximumRedirection 5
        Write-Host "Download do driver Zebra ZT230 concluido." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao baixar o driver Zebra ZT230: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $driverInstaller)) {
        Write-Host "Erro: Arquivo do driver Zebra ZT230 nao foi baixado." -ForegroundColor Red
        return
    }

    $info = Get-Item $driverInstaller
    Write-Host "Tamanho do arquivo: $([math]::Round($info.Length/1MB, 2)) MB" -ForegroundColor Cyan

    if ($info.Length -lt 10240) {
        Write-Host "Erro: arquivo do driver muito pequeno, pode estar invalido." -ForegroundColor Red
        return
    }

    try {
        Write-Host "Executando instalacao do driver Zebra ZT230..." -ForegroundColor Yellow
        Write-Host "IMPORTANTE: Conecte a impressora Zebra ZT230 antes de continuar a instalacao." -ForegroundColor Cyan
        Start-Process -FilePath $driverInstaller -Wait
        Write-Host "Driver da impressora Zebra ZT230 instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro na instalacao do driver Zebra ZT230. Execute manualmente: $driverInstaller" -ForegroundColor Red
    }
}

function Criar-AtalhoSmartClient {
    $WshShell = New-Object -ComObject WScript.Shell
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "SmartClient.lnk"

    $targetPath = "C:\Protheus-antigo\Protheus antigo\smartclient.exe"

    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = Split-Path $targetPath
    $shortcut.WindowStyle = 1
    $shortcut.Description = "Atalho para SmartClient Protheus antigo"
    $shortcut.Save()

    Write-Host "Atalho para SmartClient criado na area de trabalho." -ForegroundColor Green
}

function Instalar-ProtheusAntigo {
    Write-Host "Baixando Protheus antigo do Dropbox..." -ForegroundColor Yellow

    $urlProtheus = "Colocar link  do provedor de download aqui"
    $zipProtheus = "$tempPath\Protheus-antigo.zip"
    $destino = "C:\Protheus-antigo"

    if (-not (Test-Path $destino)) {
        New-Item -ItemType Directory -Path $destino | Out-Null
    }

    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    Invoke-WebRequest -Uri $urlProtheus -Headers $headers -OutFile $zipProtheus -MaximumRedirection 5

    $info = Get-Item $zipProtheus
    if ($info.Length -lt 10240) {
        Write-Host "Erro: arquivo Protheus antigo baixado e muito pequeno, provavelmente invalido." -ForegroundColor Red
        return
    }

    try {
        Expand-Archive -Path $zipProtheus -DestinationPath $destino -Force
    } catch {
        Write-Host "Erro ao descompactar o arquivo Protheus antigo. Pode estar corrompido." -ForegroundColor Red
        return
    }

    Criar-AtalhoSmartClient
    Write-Host "Protheus antigo baixado, extraido e atalho criado com sucesso." -ForegroundColor Green
}

function Menu {
    Clear-Host
    Write-Host "=== INSTALADOR AUTOMATIZADO ===" -ForegroundColor Cyan
    Write-Host "Escolha o que deseja instalar:" -ForegroundColor White
    Write-Host ""
    Write-Host "=== SISTEMAS ===" -ForegroundColor Green
    Write-Host "1 - SAP"
    Write-Host "2 - Configurar SAP"
    Write-Host "3 - Protheus antigo"
    Write-Host ""
    Write-Host "=== OFFICE E SEGURANCA ===" -ForegroundColor Green
    Write-Host "4 - Microsoft Office"
    Write-Host "5 - Adobe Acrobat Reader"
    Write-Host "6 - Kaspersky Endpoint Security"
    Write-Host ""
    Write-Host "=== UTILITARIOS ===" -ForegroundColor Green
    Write-Host "7 - AnyDesk (Acesso Remoto)"
    Write-Host "8 - WinRAR"
    Write-Host ""
    Write-Host "=== DRIVERS DE IMPRESSORA ===" -ForegroundColor Green
    Write-Host "9 - Driver Impressora M320F"
    Write-Host "10 - Driver Impressora Zebra ZT230"
    Write-Host ""
    Write-Host "11 - Sair" -ForegroundColor Red
    Write-Host ""

    $opcao = Read-Host "Escolha uma opcao (1-11)"
    switch ($opcao) {
        1 { Instalar-SAP }
        2 { Configurar-SAP }
        3 { Instalar-ProtheusAntigo }
        4 { Instalar-Office }
        5 { Instalar-AdobeAcrobat }
        6 { Instalar-Kaspersky }
        7 { Instalar-AnyDesk }
        8 { Instalar-WinRAR }
        9 { Instalar-DriverM320F }
        10 { Instalar-DriverZebraZT230 }
        11 { Write-Host "Saindo..." -ForegroundColor Gray; exit }
        default { Write-Host "Opcao invalida. Digite um numero de 1 a 11." -ForegroundColor Red }
    }

    Write-Host ""
    Write-Host "Pressione Enter para voltar ao menu..."
    [void][System.Console]::ReadLine()
    Menu
}

Menu