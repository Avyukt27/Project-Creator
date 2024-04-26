<#* Menu Function #>
function New-Menu {
    param (
        [string]$MenuTitle,
        [string[]]$MenuOptions
    )

    $selectedIndex = 0

    while ($true) {
        Clear-Host
        Write-Host "================ $MenuTitle ================"

        for ($i = 0; $i -lt $MenuOptions.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "> $($MenuOptions[$i])"
            } else {
                Write-Host "  $($MenuOptions[$i])"
            }
        }

        $key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

        switch ($key.VirtualKeyCode) {
            38 { if ($selectedIndex -gt 0) { $selectedIndex-- } } # Up arrow
            40 { if ($selectedIndex -lt $MenuOptions.Length - 1) { $selectedIndex++ } } # Down arrow
            13 { return $selectedIndex } # Enter
        }
    }
}

Set-Location -Path "C:\Users\$env:USERNAME\Onedrive\Code"

$languageMenu = New-Menu -MenuTitle 'Language' -MenuOptions 'Python', 'Javascript'
switch ($languageMenu) {
    0 { $language = "python" }
    1 { $language = "javascript" }
}

if (Test-Path -Path $language) {
    Write-Host -Object "Path Found! Entering Language"
    Set-Location -Path $language
} else {
    <#! Stop generating JS folder #>
    if ($language -ne "javascript") {
        Write-Host -Object "Path Not Found! Creating Language Directory"
        New-Item -Path $language -ItemType Directory
    }
}

$dirPath = Read-Host -Prompt "Enter Project Name"
$baseDirPath = $dirPath

if (Test-Path -Path $baseDirPath) {
    Write-Host -Object "Directory Already Exists! Renameing created Directory"
    $i = 1
    while (Test-Path -Path $dirPath) {
        $dirPath = $baseDirPath + $i
        $i++
    }
}

<#! Fix JS #>
if ($language -ne "javascript") {
    New-Item -Path $dirPath -ItemType Directory
    Set-Location -Path $dirPath
} else {
    $selection = New-Menu -MenuTitle 'Javascript Configuration' -MenuOptions 'HTML', 'Framework'
    switch ($selection) {
        0 {
            Set-Location -Path "Website\HTML"
            Write-Host -Object "Creating HTML, SCSS files"

            if (Test-Path -Path $baseDirPath) {
                Write-Host -Object "Directory Already Exists! Renameing created Directory"
                $i = 1
                while (Test-Path -Path $dirPath) {
                    $dirPath = $baseDirPath + $i
                    $i++
                }
            }
            New-Item -Path $dirPath -ItemType Directory
            Set-Location -Path "$dirPath"

            New-Item -Path "script.js" -ItemType File
            New-Item -Path "index.html" -ItemType File
            New-Item -Path "style.scss" -ItemType File

            $html = @"
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="style.css">
        <title>Document</title>
    </head>
    <body>
        <script src="script.js"></script>
    </body>
</html>
"@
            $html | Set-Content -Path "index.html"
        }

        1 {
            Write-Host "Creating Project Directory"

            Set-Location -Path "Website\Framework"
            if (Test-Path -Path $baseDirPath) {
                Write-Host -Object "Directory Already Exists! Renameing created Directory"
                $i = 1
                while (Test-Path -Path $dirPath) {
                    $dirPath = $baseDirPath + $i
                    $i++
                }
            }
            New-Item -Path $dirPath -ItemType Directory
            Set-Location -Path "$dirPath"

            npm create vite@latest
        }
    }
}

switch ($language) {
    "python" {
        Write-Host -Object "Creating Virtual Environment"
        python -m venv .venv
        <#* Activate Virtual Environment #>
        .venv\Scripts\activate.bat
        Write-Host -Object "Done Creating Virtual Environment"
        $selection = New-Menu -MenuTitle 'Python Configuration' -MenuOptions 'Normal', 'Web'
        switch ($selection) {
            1 {
                pip install reflex  
                pip install -U reflex
                reflex init
            }
        }
        Write-Host -Object "Python Setup Complete"
    }
}

code .