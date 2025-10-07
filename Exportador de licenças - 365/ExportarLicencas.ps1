Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Mapa SkuId → SkuPartNumber
$skuPartMap = @{}
$skus = Get-MgSubscribedSku
foreach ($sku in $skus) {
    if ($sku.SkuId -and $sku.SkuPartNumber) {
        $skuPartMap[$sku.SkuId.ToString()] = $sku.SkuPartNumber
    }
}

# Mapa tradução para nomes amigáveis
$licenseNameMap = @{
    "ENTERPRISEPACK"        = "Office 365 E3"
    "E3"                    = "Office 365 E3"
    "BUSINESS_PREMIUM"      = "Microsoft 365 Business Premium"
    "M365_BUSINESS_BASIC"   = "Microsoft 365 Business Basic"
    "POWER_BI_PRO"          = "Power BI Pro"
    "FLOW_FREE"             = "Power Automate (Gratuito)"
    "PROJECTESSENTIALS"     = "Project Essentials"
    "VISIOONLINE_PLAN1"     = "Visio Online Plan 1"
    "EMS"                   = "Enterprise Mobility + Security (EMS)"
    "O365_BUSINESS_PREMIUM"     = "Microsoft 365 Business Premium"
    "O365_BUSINESS_ESSENTIALS"  = "Microsoft 365 Business Essentials"
    "POWER_BI_STANDARD"         = "Power BI Standard"
    "PBI_PREMIUM_PER_USER"      = "Power BI Premium"
    "EXCHANGESTANDARD"          = "Exchange Standard"
    "EXCHANGEENTERPRISE"        = "Exchange Enterprise"
    "EXCHANGEDESKLESS"          = "Exchange Online Kiosk"
    "POWERAPPS_DEV"             = "Power Apps Developer Plan"
}

# Obter todos os usuários 
$users = Get-MgUser -All -Property "DisplayName", "UserPrincipalName", "AssignedLicenses", "Department"

$exportData = foreach ($user in $users) {
    if ($user.AssignedLicenses.Count -eq 0) {
        continue
    }

    foreach ($license in $user.AssignedLicenses) {
        $skuId = $license.SkuId.ToString()
        $licenseName = $null

        if ($skuPartMap.ContainsKey($skuId)) {
            $skuPart = $skuPartMap[$skuId]
            if ($licenseNameMap.ContainsKey($skuPart)) {
                $licenseName = $licenseNameMap[$skuPart]
            } else {
                $licenseName = $skuPart
            }
        } else {
            $licenseName = $skuId
        }

        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            Department        = $user.Department
            License           = $licenseName
        }
    }
}

$desktopPath = [Environment]::GetFolderPath("Desktop")
$exportPath = Join-Path $desktopPath "LicencasM365.csv"

# Exporta CSV com delimitador ponto e vírgula
$exportData | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
