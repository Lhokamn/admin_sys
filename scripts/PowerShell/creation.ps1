# Varible modifiable

$defaultPassword = "1234"
$defaultUPN = ""
$ADBaseDN="dc=,dc="

<# Ajout du framework WPF #>
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName presentationCore

# Création de la fenêtre 
$window = New-Object System.Windows.Forms.Form
$window.ClientSize = '750,370'
$window.Text = "Creation poste"
$window.MaximizeBox = $false

# Création de la tabControl 
$tabControl = New-object System.Windows.Forms.TabControl
$tabControl.Location = "0,0"
$tabControl.Width = 740
$tabControl.Height = $window.Height - 100

# Création de tabPage pour la création d'un nouvel utilisateur
$tabUser = New-object System.Windows.Forms.Tabpage
$tabUser.Text = "Création utilisateur"
$tabControl.Controls.Add($tabUser)

# Création de la tabpage pour la préparation des postes
$tabPoste = New-object System.Windows.Forms.Tabpage
$tabPoste.Text = "préparation poste"
$tabControl.Controls.Add($tabPoste)

# ========= Création du panel Utilisateur ========= #
$panelUser = New-object System.Windows.Forms.Panel
$panelUser.AutoSize = $true
$panelUser.Location = "0,0"
$tabUser.Controls.Add($panelUser)

# Création du groupBox pour les attributs de l'utilisateur

$groupBoxUser = New-Object System.Windows.Forms.GroupBox
$groupBoxUser.Text = "Utilisateur"
$groupBoxUser.Location = "10,10"
$groupBoxUser.AutoSize = $true
$panelUser.Controls.Add($groupBoxUser)

$sizeLabel = "100,20"
$sizeTextBox = "200,20"
$YLocation = 20

# Label + TextBOX du prénom
$labelPrenom = New-object System.Windows.Forms.Label
$labelPrenom.Text = "Prénom"
$labelPrenom.Size = $sizeLabel
$labelPrenom.Location = "5,$YLocation"
$labelPrenom.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$groupBoxUser.Controls.Add($labelPrenom)

$textBoxPrenom = New-Object System.Windows.Forms.TextBox
$textBoxPrenom.Size = $sizeTextBox 
$textBoxPrenom.Location = "115,$YLocation"
$groupBoxUser.Controls.Add($textBoxPrenom)

$YLocation += 25
# Label + TextBox du Prénom
$labelNom = New-object System.Windows.Forms.Label
$labelNom.Text = "Nom"
$labelNom.Size = $sizeLabel
$labelNom.Location = "5,$YLocation"
$labelNom.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$groupBoxUser.Controls.Add($labelNom)

$textBoxNom = New-Object System.Windows.Forms.TextBox
$textBoxNom.Size = $sizeTextBox 
$textBoxNom.Location = "115,$YLocation"
$groupBoxUser.Controls.Add($textBoxNom)

$YLocation += 25
# Label + TextBox du mot de passe
$labelPassword = New-object System.Windows.Forms.Label
$labelPassword.Text = "Mot de passe"
$labelPassword.Size = $sizeLabel
$labelPassword.Location = "5,$YLocation"
$labelPassword.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$groupBoxUser.Controls.Add($labelPassword)

$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Size = $sizeTextBox 
$textBoxPassword.Location = "115,$YLocation"
$groupBoxUser.Controls.Add($textBoxPassword)

$YLocation += 25
# Label + TextBox de l'identifiant
$labelIdentifiant = New-object System.Windows.Forms.Label
$labelIdentifiant.Text = "Identifiant"
$labelIdentifiant.Size = $sizeLabel
$labelIdentifiant.Location = "5,$YLocation"
$labelIdentifiant.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$groupBoxUser.Controls.Add($labelIdentifiant)

$textBoxIdentifiant = New-Object System.Windows.Forms.TextBox
$textBoxIdentifiant.Size = $sizeTextBox 
$textBoxIdentifiant.Location = "115,$YLocation"
$groupBoxUser.Controls.Add($textBoxIdentifiant)

$YLocation += 25
# Label + TextBox + ComboBox
$labelMail = New-object System.Windows.Forms.Label
$labelMail.Text = "Mail"
$labelMail.Size = $sizeLabel
$labelMail.Location = "5,$YLocation"
$labelMail.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$groupBoxUser.Controls.Add($labelMail)

$textBoxMail = New-Object System.Windows.Forms.TextBox
$textBoxMail.Size = "85,20" 
$textBoxMail.Location = "115,$YLocation"
$groupBoxUser.Controls.Add($textBoxMail)

$comboBoxUPN = New-Object System.Windows.Forms.ComboBox
$comboBoxUPN.Size = "100,20"
$comboBoxUPN.Location = "215,$YLocation"
$groupBoxUser.Controls.Add($comboBoxUPN)


#Création du groupBox pour les groupes
$groupBoxGroup = New-Object System.Windows.Forms.GroupBox
$groupBoxGroup.Text = "Groupes AD"
$groupBoxGroup.Location = "365,10"
$groupBoxGroup.AutoSize = $true
$panelUser.Controls.Add($groupBoxGroup)

$comboBoxGroupe = New-Object System.Windows.Forms.ListBox
$comboBoxGroupe.Size = "300,220"
$comboBoxGroupe.Location = "5,20"
$groupBoxGroup.Controls.Add($comboBoxGroupe)

# ========= Création du panel exécution ========= #
$panelExec = New-object System.Windows.Forms.Panel
$panelExec.size = "1008,50"
$panelExec.Location = New-Object System.Drawing.Point(20, 310)
$window.Controls.Add($panelExec)

# Label pour connaitre l'utilisateur courant
$labelUserEnv = New-object System.Windows.Forms.Label
$labelUserEnv.Text = "Utilisteur du script : $env:USERNAME"
$labelUserEnv.Size = "200,30"
$panelExec.Controls.Add($labelUserEnv)

# Label infomatif
$labelUserPassword = New-Object System.Windows.Forms.Label
$labelUserPassword.Text = "Mot de passe :"
$labelUserPassword.Size = "100,30"
$labelUserPassword.Location = "0,30"
$panelExec.Controls.Add($labelUserPassword)

# TextBox pour le mot de passe de l'utilisateur
$textboxAdminPassword = New-Object System.Windows.Forms.TextBox
$textboxAdminPassword.Size = "200,30"
$textboxAdminPassword.Location = "108, 30"
$panelExec.Controls.Add($textboxAdminPassword)

# Bouton pour executer le script
$buttonExec = New-Object System.Windows.Forms.Button
$buttonExec.Text = "Commencer le script"
$buttonExec.Size = "150,45"
$buttonExec.Location = "330,5"
$panelExec.Controls.Add($buttonExec)

# Bonton pour redémarrer le script
$buttonReboot = New-Object System.Windows.Forms.Button
$buttonReboot.Text = "Redémarrer"
$buttonReboot.Size = "150,45"
$buttonReboot.Location = "550,5"
$panelExec.Controls.Add($buttonReboot)

# ========= Création du panel des installation poste ========= #
$panelPoste = New-Object System.Windows.Forms.Panel
$panelPoste.AutoSize = $true
$tabPoste.Controls.Add($panelPoste)

$groupBoxInstall = New-Object System.Windows.Forms.GroupBox
$groupBoxInstall.AutoSize = $true
$groupBoxInstall.Text = "Choix d'action"
$panelPoste.Controls.Add($groupBoxInstall)

# Radio Button pous installer toutes les app
$radioButtonAll = New-Object System.Windows.Forms.RadioButton
$radioButtonAll.Text = "Install all apps"
$radioButtonAll.Location = "5,20"
$groupBoxInstall.Controls.Add($radioButtonAll)

# Radio Button pour installer une app à complementer avec comboBoxOneApp
$radioButtonOneApp = New-Object System.Windows.Forms.RadioButton
$radioButtonOneApp.Text = "Install One apps"
$radioButtonOneApp.Location = "5,55"
$radioButtonOneApp.Size = "100,40"
$groupBoxInstall.Controls.Add($radioButtonOneApp)

# textBox pour récuperer une app
$comboBoxOneApp = New-Object System.Windows.Forms.comboBox
$comboBoxOneApp.AutoSize = $true
$comboBoxOneApp.Location = "5,100"
$groupBoxInstall.Controls.Add($comboBoxOneApp)

$window.Controls.Add($tabControl)



# Fonction 

function Initialize-Fields {
    
    # Intialisation du mot de passe par défaut
    $textBoxPassword.Text = $defaultPassword
    $comboBoxUPN.Text = $defaultUPN
    
}

function Add-ADUser {

    $userPassword = ConvertTo-SecureString -AsPlainText $textBoxPassword.Text

    New-ADUser -Name "$($textBoxPrenom.Text) $($textBoxNom.Text))" `
               -GivenName $textBoxPrenom.Text `
               -Surname $textBoxNom.Text `
               -SamAccountName $textBoxIdentifiant.Text
               -UserPrincipaleName "$($textBoxMail.Text)@$($comboBoxUPN.Text)"
               -AccountPassword $userPassword
               -Enabled $true
    
}

# Evenement
$buttonExec.Add_Click({
    switch ($tabControl.SelectedIndex) {
        0 {
            Add-ADUser
        }
        1 {
            if ($radioButtonOneApp.Checked){
                Install-OneApp -App $comboBoxOneApp.SelectedItem
            }
            else {
                Install-AllApp
            }
        }
        Default {
            Write-Host "ERREUR : Onglet sélectionné inextitant" -ForegroundColor "Red"
        }
    }
})

$textBoxPrenom.add_TextChanged({
    if ($textBoxPrenom.Text.size -gt 0){
        $textBoxIdentifiant.Text="$($textBoxPrenom.Text.substring(0,1))."
    }
    else{
        $textBoxIdentifiant.text = $textBoxIdentifiant.Text.Split(".")[1]
    }
})

# Début Script
Initialize-Fields
$window.ShowDialog()