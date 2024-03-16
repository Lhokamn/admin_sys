<#
    PARAMéTRAGE DU SCRIPT
#>
$Credential = $null
$DefaultUserPassword = ""
$NETLOGONLocation = ""
$DefaultUPNSuffix = ""
$DefaultUserLogonScript = ""
$UsersOrganizationalUnit = ""
$DefaultGroups = @()

# Les valeurs sont récupérées automatiquement en scannant tous les utilisateurs de l'AD.
[System.Collections.ArrayList]$Departments = @()
[System.Collections.ArrayList]$UserTitles = @()
[System.Collections.ArrayList]$UserWorker = @()
[System.Collections.ArrayList]$UserFunction = @()
[System.Collections.ArrayList]$Companies = @()
[System.Collections.ArrayList]$States = @()

# Le fonctionnement des heures de login est assez compliqué à expliquer et à faire à la main.
# Basiquement la semaine est découpée en 21 crénaux de 8 heures donc 21 octets, et on se sert de chaque bit de chaque nombre
# pour déterminer l'autorisation.
# Cependant les mettre à la main est déjà compliqué en plus il faut prendre en compte le décalage horaire.
# Pour en ajouter simplement, d'abord le parramétrer à la main sur un utilisateur puis récupérer les valeurs avec
#   (Get-ADUser -Filter "DisplayName -eq 'Prénom Nom'" -Properties LogonHours).LogonHours
# Et enfin les formater comme les tableaux ci dessous.
$TimeRestrictions = @{
    "Lun. Ven. 7h-22h (default)" = [byte[]](0, 0, 0, 192, 255, 31, 192, 255, 31, 192, 255, 31, 192, 255, 31, 192, 255, 31, 0, 0, 0); 
    "Connexion interdite" = [byte[]](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}

# L'interface graphique
$XamlGUI = '
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Create_ADUser_GUI"
        mc:Ignorable="d"
        Title="AD User Creator" Height="535" Width="1048"
        ResizeMode="NoResize">
    <Grid Margin="0,0,4,0" Height="457" VerticalAlignment="Top">
        <GroupBox Header="Utilisateur" HorizontalAlignment="Left" Height="450" Margin="10,10,0,0" VerticalAlignment="Top" Width="450">
            <Grid Margin="0,0,-2,-3">
                <Label Content="Prénom" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserGivenNameBox" HorizontalAlignment="Left" Height="23" Margin="66,13,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="234"/>
                <Label Content="Nom" HorizontalAlignment="Left" Margin="10,38,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserSurnameBox" HorizontalAlignment="Left" Height="23" Margin="66,41,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="234"/>
                <Label Content="Password" HorizontalAlignment="Left" Margin="10,69,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserPasswordBox" HorizontalAlignment="Left" Height="23" Margin="66,69,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="234"/>
                <Label Content="Login" HorizontalAlignment="Left" Margin="10,127,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserLoginBox" HorizontalAlignment="Left" Height="23" Margin="66,130,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="218"/>
                <Label Content="@" HorizontalAlignment="Left" Margin="284,127,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserUPNSuffixesBox" HorizontalAlignment="Left" Margin="305,131,0,0" VerticalAlignment="Top" Width="125"/>
                <Label Content="Panieres" HorizontalAlignment="Left" Margin="10,155,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserBasketBox" HorizontalAlignment="Left" Height="23" Margin="66,158,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="234"/>
                <Label Content="Script" HorizontalAlignment="Left" Margin="10,182,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserLogonScriptBox" HorizontalAlignment="Left" Margin="66,186,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="OU" HorizontalAlignment="Left" Margin="10,213,0,0" VerticalAlignment="Top" Width="36"/>
                <ComboBox Name="UserOUBox" HorizontalAlignment="Left" Margin="66,214,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="Société" HorizontalAlignment="Left" Margin="10,239,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserCompanyBox" HorizontalAlignment="Left" Margin="66,241,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="Service" HorizontalAlignment="Left" Margin="10,264,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserDepartmentBox" HorizontalAlignment="Left" Margin="66,268,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="Title" HorizontalAlignment="Left" Margin="10,291,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserTitleBox" HorizontalAlignment="Left" Margin="66,293,0,0" VerticalAlignment="Top" Width="234"/>

                <Label Content="Grade" HorizontalAlignment="Left" Margin="10,316,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserFunctionBox" HorizontalAlignment="Left" Margin="66,318,0,0" VerticalAlignment="Top" Width="234"/>

                <Label Content="Metier" HorizontalAlignment="Left" Margin="10,341,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserWorkBox" HorizontalAlignment="Left" Margin="66,343,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="N 1" HorizontalAlignment="Left" Margin="10,366,0,0" VerticalAlignment="Top"/>
                <TextBox Name="UserManagerBox" HorizontalAlignment="Left" Margin="66,368,0,0" VerticalAlignment="Top" Width="234"/>
                <Label Content="Restrictions Horaires" HorizontalAlignment="Left" Margin="10,391,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="UserClockRestrictionBox" HorizontalAlignment="Left" Margin="133,393,0,0" VerticalAlignment="Top" Width="167"/>
            </Grid>
        </GroupBox>
        <GroupBox Header="Groupes" HorizontalAlignment="Left" Height="401" Margin="465,10,0,0" VerticalAlignment="Top" Width="315">
            <ListBox Name="GroupsBox" SelectionMode="Multiple" HorizontalAlignment="Left" Height="380" Margin="0,0,-2,-2" VerticalAlignment="Top" Width="305"/>
        </GroupBox>
        <GroupBox Header="Email Principal" HorizontalAlignment="Left" Height="50" Margin="785,10,0,0" VerticalAlignment="Top" Width="243">
            <TextBox Name="MainEmailBox" HorizontalAlignment="Left" Height="20" Margin="4,3,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="223"/>
        </GroupBox>
        <GroupBox Header="Aliases" HorizontalAlignment="Left" Height="265" Margin="785,65,0,0" VerticalAlignment="Top" Width="243">
            <ListBox Name="AliasListBox" HorizontalAlignment="Left" Height="245" VerticalAlignment="Top" Width="233" Margin="0,0,-2,-3"/>
        </GroupBox>
        <TextBox Name="AliasTextBox" HorizontalAlignment="Left" Height="20" Margin="785,335,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="145"/>
        <Button Name="AddAliasButton" Content="Add" HorizontalAlignment="Left" Height="20" Margin="935,335,0,0" VerticalAlignment="Top" Width="45"/>
        <Button Name="DelAliasButton" Content="Del" HorizontalAlignment="Left" Height="20" Margin="985,335,0,0" VerticalAlignment="Top" Width="43"/>
        <Button Name="ResetGUIButton" Content="Reset" Margin="785,367,198,42"/>
        <Button Name="LoadUserButton" Content="Charger" Margin="845,367,133,42"/>
        <Button Name="SaveUserButton" Content="Créer / Sauvegarder" Margin="910,367,10,42"/>
        <StatusBar HorizontalAlignment="Left" Height="39" Margin="0,460,-7,-34" VerticalAlignment="Top" Width="1045">
            <Label Name="InfoLabel" Content="" Height="29" Width="785"/>
        </StatusBar>
    </Grid>
</Window>
'
<#
##
    Début du script
##
#>

<# Ajout du framework WPF #>
Add-Type -AssemblyName PresentationFramework
#Import-Module ActiveDirectory

<### Fonctions Utilitaires ###>

<# Remplacement des accents par leur équivalent ASCII et retire tous les autres caractères non standard.#>
function Remove-Diacritics {
    Param(
        [String]$inputString
    )
    $sb = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($inputString))
    return($sb -replace '[^a-zA-Z0-9 ]', '')
}

<# Import des valeurs par défaut depuis l'AD #>
function Import-ADDefaultValues {
    $global:Companies = @()
    $global:Departments = @()
    $global:UserTitles = @()
    $global:States = @()
    $global:UserWorker = @()
    $global:UserFunction = @()
    ForEach ($User in (Get-ADUser -SearchBase $UsersOrganizationalUnit -Filter * -Properties Company, Title, Department, State,employeeType,employeeID)) {
        if ($Companies -notcontains $User.Company) {
            $Companies.Add($User.Company) > $null
        }
        if ($Departments -notcontains $User.Department) {
            $Departments.Add($User.Department) > $null
        }
        if ($UserTitles -notcontains $User.Title) {
            $UserTitles.Add($User.Title) > $null
        }
        if ($States -notcontains $User.State) {
            $States.Add($User.State) > $null
        }
        if ($UserWorker -notcontains $User.employeeType){
            $UserWorker.Add($User.employeeType) > $null
        }
        if ($UserFunction -notcontains $User.employeeID) {
            $UserFunction.Add($User.employeeID) > $null
        }
    }
}

<# Demander / Récupérer les credentials de l'AD si déjà rentrés une fois #>
function Get-ADCredential {
    # Todo lmao
    if ($null -eq $global:Credential) {
        $global:Credential = Get-Credential
    }
    $global:Credential
}

<# Crée l'interface utilisateur avec le XAML fourni #>
function Import-GUI {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GUIXaml
    )
    $GUIXaml = $GUIXaml -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N'
    [XML]$XAML = $GUIXaml
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $window = [Windows.Markup.XamlReader]::Load($reader)
    }
    catch {
        Write-Warning $_.Exception
        pause
        throw
    }
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try {
            Set-Variable -Name "GUI_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop -Scope global
        }
        catch {
            throw
        }
    }
    $window
}

<# Importe un utilisateur depuis l'AD #>
<# à refactoriser, utiliser une classe custom etc #>
function Import-ADUser {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$UserLogin
    )
    Reset-Fields
    $User = Get-ADUser -Filter "UserPrincipalName -eq '$UserLogin'" -Properties *
    if ($null -eq $User) {
        return $GUI_InfoLabel.Content = "L'utilisateur $UserLogin n'a pas pu être importé."
    }
    else {
        $GUI_InfoLabel.Content = "L'utilisateur $UserLogin a été importé."
    }
    $GUI_UserGivenNameBox.Text = $User.GivenName
    $GUI_UserSurnameBox.Text = $User.Surname
    $GUI_UserPasswordBox.Text = ""
    $GUI_UserLoginBox.Text = ($User.UserPrincipalName -split "@")[0]
    $GUI_UserUPNSuffixesBox.SelectedItem = ($User.UserPrincipalName -split "@")[1]
    $GUI_UserBasketBox.Text = $User.City # Ew.
    $GUI_UserLogonScriptBox.SelectedItem = $User.ScriptPath
    $GUI_UserOUBox.SelectedItem = ($User.DistinguishedName -split ",?[A-Z][A-Z]=")[2]
    $GUI_UserCompanyBox.SelectedItem = $User.Company
    $GUI_UserDepartmentBox.SelectedItem = $User.Department
    $GUI_UserTitleBox.SelectedItem = $User.Title
    ForEach ($Group in $User.MemberOf) {
        $GUI_GroupsBox.SelectedItems.Add(($Group -split ",?[A-Z][A-Z]=")[1])
    }
    ForEach ($Key in $TimeRestrictions.Keys) {
        if ($null -eq $User.LogonHours) {
            $GUI_UserClockRestrictionBox.SelectedItem = "Pas de restrictions"
            break
        }
        if ($null -eq (Compare-Object -ReferenceObject $TimeRestrictions.$Key -DifferenceObject $User.LogonHours -PassThru)) {
            $GUI_UserClockRestrictionBox.SelectedItem = $Key
        }
    }
    ForEach ($Alias in ($User.ProxyAddresses | Sort-Object)) {
        if ($Alias -clike "SMTP:*") {
            $GUI_MainEmailBox.Text = $Alias -replace 'SMTP:', ''
        }
        else {
            $GUI_AliasListBox.Items.Add(($Alias -replace 'smtp:', ''))
        }
    }
}

<# Sauvegarder l'utilisateur dans l'AD #>
<# à refactoriser pour ne pas toucher aux champs non modifiés manuellement #>
function Save-ADUser {
    $User = Get-ADUser -Filter "UserPrincipalName -eq '$($GUI_UserLoginBox.Compose())'" -Properties *
    $OU = Get-ADOrganizationalUnit -SearchBase $UsersOrganizationalUnit -Filter "Name -eq '$($GUI_UserOUBox.Text)'" -Properties *
    $BoxInput = ""
    if ($null -eq $OU) {
        return $GUI_InfoLabel.Content = "L'OU $($GUI_UserOUBox.Text) n'a pas été trouvée sous $UsersOrganizationalUnit."
    }
    if ($null -eq $User) {
        if ($GUI_UserPasswordBox.Text -eq "") {
            return $GUI_InfoLabel.Content = "Le mot de passe ne peut être vide lors de la création d'un utilisateur."
        }
        $GUI_InfoLabel.Content = "Création de l'utilisateur $($GUI_UserLoginBox.Compose())."
        $User = New-ADUser -Credential (Get-ADCredential) -Path $OU.DistinguishedName -EmailAddress "$($GUI_UserLoginBox.Compose())" -SamAccountName "$($GUI_UserLoginBox.Text -replace '\.','')" -Name (Remove-Diacritics "$($GUI_UserGivenNameBox.Text) $($GUI_UserSurnameBox.Text)") -PassThru -OtherAttributes @{
            'UserPrincipalName' = "$($GUI_UserLoginBox.Compose())";
        }
        $User = $null
        $User = Get-ADUser -Filter "UserPrincipalName -eq '$($GUI_UserLoginBox.Compose())'" -Properties *
        if ($null -eq $User) {
            Start-Sleep 2
            $User = Get-ADUser -Filter "UserPrincipalName -eq '$($GUI_UserLoginBox.Compose())'" -Properties *
            if ($null -eq $User) {
                return $GUI_InfoLabel.Content = "L'utilisateur $($GUI_UserLoginBox.Compose()) à été crée mais n'a pas pu être rempli."
            }
        }
        Set-ADAccountPassword -Credential (Get-ADCredential) -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $GUI_UserPasswordBox.Text -Force)
        Enable-ADAccount -Identity $User -Credential (Get-ADCredential)
    }
    else {
        $BoxInput = [System.Windows.MessageBox]::Show("Voulez-vous écraser l'utilisateur existant ?", "ATTENTION", 'YesNo', 'Warning')
        switch ($BoxInput) {
            'Yes' {
                $GUI_InfoLabel.Content = "Mise à jour de l'utilisateur $($GUI_UserLoginBox.Compose())."
                $User = Rename-ADObject -Identity $User -NewName "$(Remove-Diacritics $GUI_UserGivenNameBox.Text) $($GUI_UserSurnameBox.Text)" -Credential (Get-ADCredential) -PassThru
                $User = Get-ADUser -Filter "UserPrincipalName -eq '$($GUI_UserLoginBox.Compose())'" -Properties *
                $User.'UserPrincipalName' = $GUI_UserLoginBox.Compose();
                $User.'EmailAddress' = $GUI_UserLoginBox.Compose();
                Set-ADUser -Instance $User -Credential (Get-ADCredential)
                Set-ADUser -Identity $User -SamAccountName "$($GUI_UserLoginBox.Text -replace '\.','')" -Credential (Get-ADCredential)
                Move-ADObject -Credential (Get-ADCredential) -Identity $User -TargetPath $OU.DistinguishedName -Confirm:$false
                $User = Get-ADUser -Filter "UserPrincipalName -eq '$($GUI_UserLoginBox.Compose())'" -Properties *
                if ($GUI_UserPasswordBox.Text) {
                    Set-ADAccountPassword -Credential (Get-ADCredential) -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $GUI_UserPasswordBox.Text -Force)
                }
            }
            'No'{
                $GUI_InfoLabel.Content = "Annulation de la modification."
                break;
            }
        }
    }
    # Sécurisation
    if ($BoxInput -notlike "No"){
        $ProxyAddresses = ""
        $ProxyAddresses += "SMTP:$($GUI_MainEmailBox.Text)"
        ForEach ($Item in $GUI_AliasListBox.Items) {
            $ProxyAddresses += ",smtp:$Item"
        }
        $User.'GivenName' = $GUI_UserGivenNameBox.Text
        $User.'Surname' = $GUI_UserSurnameBox.Text;
        $User.'DisplayName' = "$($GUI_UserGivenNameBox.Text) $($GUI_UserSurnameBox.Text)";
        $User.'Office' = $OU.City;
        $User.'facsimileTelephoneNumber' = "$($OU.Description)";
        $User.'Title' = "$($GUI_UserTitleBox.SelectedItem)";
        $User.'StreetAddress' = $OU.StreetAddress;
        #modif
        $User.'City' = $OU.City;
        $User.'HomeDrive' = "P:";
        $User.'HomeDirectory' = "$($GUI_UserBasketBox.Text)";
        #fin modif
        $User.'PostalCode' = $OU.PostalCode;
        $User.'Country' = $OU.Country;
        $User.'ScriptPath' = $GUI_UserLogonScriptBox.SelectedItem;
        $User.'Department' = "$($GUI_UserDepartmentBox.SelectedItem)";
        $User.'Company' = "$($GUI_UserCompanyBox.SelectedItem)";
        $User.'ProxyAddresses' = ($ProxyAddresses -split ",");
        $User.'State' = $OU.State;

        # Mise à jour de l'utilisateur
        # fait en plusieurs fois car si nous faisons tout en une seule commande, cela ne marche pas
        Set-ADUser -Instance $User -Credential (Get-ADCredential)
        
        Set-ADUSer -Identity $User -Manager $GUI_UserManagerBox.text -Credential (Get-ADCredential)
        Set-ADUser -Identity $User -Replace @{'EmployeeType'="$($GUI_UserWorkBox.SelectedItem)"} -Credential (Get-ADCredential)
        Set-ADUser -Identity $User -Replace @{'EmployeeID'="$($GUI_UserFunctionBox.SelectedItem)"} -Credential (Get-ADCredential)
        Set-ADUser -Identity $User -Replace @{'LogonHours'="$($TimeRestrictions.$GUI_UserClockRestrictionBox.SelectedItem)"} -Credential (Get-ADCredential)
        ForEach ($Group in ($GUI_GroupsBox.Items)) {
            $MemberOf = $User.MemberOf | ForEach-Object -Process { ($_ -split ",?[A-Z][A-Z]=")[1] }
            if ($MemberOf -contains $Group -and $GUI_GroupsBox.SelectedItems -notcontains $Group) {
                $GroupID = Get-ADGroup $Group
                Remove-ADGroupMember -Identity $GroupID -Members $User -Credential (Get-ADCredential)
            }
            if ($MemberOf -notcontains $Group -and $GUI_GroupsBox.SelectedItems -contains $Group) {
                $GroupID = Get-ADGroup $Group
                Add-ADGroupMember -Identity $GroupID -Members $User -Credential (Get-ADCredential)
            }
        }
    }
}

function Initialize-Fields {
    # Recherche et ajout des domaines disponibles et définition de la valeur par défaut.
    ForEach ($UPNSuffix in ((Get-ADForest).UPNSuffixes | Sort-Object)) {
        $GUI_UserUPNSuffixesBox.Items.Add($UPNSuffix) > $null
    }
    # Recherche et ajout des scripts dans le NETLOGON et définition de la valeur par défaut.
    $GUI_UserLogonScriptBox.Items.Add("") > $null
    ForEach ($File in (Get-Item "$NETLOGONLocation\*" | Sort-Object Name)) {
        $GUI_UserLogonScriptBox.Items.Add($File.Name) > $null
    }
    #Recherche et ajout des Sous-OU dans l'OU des utilisateurs.
    ForEach ($OU in (Get-ADOrganizationalUnit -SearchBase $UsersOrganizationalUnit -Filter * | Sort-Object Name)) {
        $GUI_UserOUBox.Items.Add($OU.Name) > $null
    }
    # Recherche et ajout des Groupes
    ForEach ($Group in (Get-ADGroup -Filter "*" |`
        Where-Object {           # Bloque tous les groupes possédant l'un de ces mots dans leur chemin
            ($_.DistinguishedName -notmatch "=(Site|cmp|dpt|Builtin|Users),")
        } |`
        Sort-Object Name))
    {
        $GUI_GroupsBox.Items.Add($Group.Name) > $null
    }
    # Ajout des valeurs récupérées dans l'AD
    ForEach ($Company in ($Companies | Sort-Object)) {
        $GUI_UserCompanyBox.Items.Add($Company) > $null
    }
    ForEach ($Department in ($Departments | Sort-Object)) {
        $GUI_UserDepartmentBox.Items.Add($Department) > $null
    }
    ForEach ($Title in ($UserTitles | Sort-Object)) {
        $GUI_UserTitleBox.Items.Add($Title) > $null
    }
    ForEach ($Worker in ($UserWorker | Sort-Object)){
        $GUI_UserWorkBox.Items.Add($Worker) > $null
    }
    ForEach ($Grade in ($UserFunction | Sort-Object)){
        $GUI_UserFunctionBox.Items.Add($Grade) > $null
    }
    $GUI_UserClockRestrictionBox.Items.Add("Pas de restrictions (associés et DM)") > $null
    ForEach ($Key in ($TimeRestrictions.Keys | Sort-Object)) {
        if ($Key -eq "Pas de restrictions (associés et DM)" -or $Key -eq "Connexion interdite") {
            continue
        }
        $GUI_UserClockRestrictionBox.Items.Add($Key) > $null
    }
    $GUI_UserClockRestrictionBox.Items.Add("Connexion interdite") > $null
}

<# Fonction de remise à zéro des champs #>
function Reset-Fields {
    $GUI_UserGivenNameBox.Text = ""
    $GUI_UserSurnameBox.Text = ""
    $GUI_UserPasswordBox.Text = $DefaultUserPassword
    $GUI_UserLoginBox.Text = ""
    $GUI_UserUPNSuffixesBox.SelectedItem = $DefaultUPNSuffix
    $GUI_UserLogonScriptBox.SelectedItem = $DefaultUserLogonScript
    $GUI_UserOUBox.SelectedIndex = -1
    $GUI_UserCompanyBox.SelectedIndex = -1
    $GUI_UserDepartmentBox.SelectedIndex = -1
    $GUI_UserTitleBox.SelectedIndex = -1
    $GUI_UserClockRestrictionBox.SelectedItem = "Lun. Ven. 7h-22h (default)"
    While ($GUI_GroupsBox.SelectedItems) {
        $GUI_GroupsBox.SelectedItems.Remove($GUI_GroupsBox.SelectedItems[0])
    }
    ForEach ($Group in $DefaultGroups) {
        $GUI_GroupsBox.SelectedItems.Add($Group) | Out-Null
    }
    $GUI_GroupsBox.SelectedItems.Add("") | Out-Null
    $GUI_MainEmailBox.Text = ""
    While ($GUI_AliasListBox.Items) {
        $GUI_AliasListBox.Items.Remove($GUI_AliasListBox.Items[0])
    }
    $GUI_InfoLabel.Content = "Mise à zéro des champs."
}

<# Met à jour le texte de la boîte de login #>
function Update-UserLogin() {
    $GUI_UserLoginBox.Text = "$(Remove-Diacritics $GUI_UserGivenNameBox.Text[0]).$((Remove-Diacritics $GUI_UserSurnameBox.Text) -replace ' ','')".ToLower()
}

<# Met à jour l'email principal de l'utilisateur #>
function Update-MainEmail {
    $GUI_MainEmailBox.Text = $GUI_UserLoginBox.Compose()
}

<# Ajoute un alias à l'utilisateur #>
function Add-Alias {
    if ($GUI_AliasListBox.Items -notcontains $GUI_AliasTextBox.Text) {
        $GUI_AliasListBox.Items.Add($GUI_AliasTextBox.Text)
        $GUI_AliasTextBox.Text = ""
    }
}

<# Retire un alias à l'utilisateur #>
function Remove-Alias {
    if ($GUI_AliasListBox.SelectedItem) {
        $GUI_AliasListBox.Items.Remove($GUI_AliasListBox.SelectedItem)
        $GUI_AliasListBox.SelectedIndex = -1
    }
}

<# Field Events functions Definition #>

function Initialize-UserGivenNameBoxEvents {
    $GUI_UserGivenNameBox.add_TextChanged({ Update-UserLogin })
    $GUI_UserGivenNameBox.add_LostFocus({ $GUI_UserGivenNameBox.Text = (Get-Culture).TextInfo.ToTitleCase($GUI_UserGivenNameBox.Text) })
}

function Initialize-UserSurnameBoxEvents {
    $GUI_UserSurnameBox.add_TextChanged({ Update-UserLogin })
    $GUI_UserSurnameBox.add_LostFocus({ $GUI_UserSurnameBox.Text = $GUI_UserSurnameBox.Text.ToUpper() })
}

function Initialize-UserLoginBoxEvents {
    $GUI_UserLoginBox.add_TextChanged({ Update-UserBasket })
    $GUI_UserLoginBox.add_TextChanged({ Update-MainEmail })
}

function Initialize-ResetGUIButton {
    $GUI_ResetGUIButton.Add_Click({ Reset-Fields })
}

function Initialize-FieldsEvents {
    Initialize-UserGivenNameBoxEvents
    Initialize-UserSurnameBoxEvents
    Initialize-ResetGUIButton
    Initialize-UserLoginBoxEvents
    $GUI_SaveUserButton.Add_Click({ Save-ADUser })
    $GUI_LoadUserButton.Add_Click({ Import-ADUser $GUI_UserLoginBox.Compose() })
    $GUI_AddAliasButton.add_Click({ Add-Alias })
    $GUI_DelAliasButton.add_Click({ Remove-Alias })
}





<# Main function #>
function Main {
    # Si on est sur un contrôleur de domaine on demande les droits d'admin, sinon les logonhours remontent pas. (wtf ?)
    if ((Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 2) {
        Write-Host "Ce script ne doit pas être lancé sur le contrôleur de domaine lui même."
        return pause
    }
    if ($null -eq (Get-Module -list ActiveDirectory)) {
        Write-Host "Ce script ne peut pas fonctionner sans RSAT et le module ActiveDirectory."
        return pause
    }
    $window = Import-GUI -GUIXaml $XamlGUI
    #Write-Output $window.getType()
    Import-ADDefaultValues
    Initialize-Fields
    Initialize-FieldsEvents
    Reset-Fields
    Get-Variable GUI_*
    $GUI_UserLoginBox | Add-Member -MemberType ScriptMethod -Name "Compose" -Value { -Join ($GUI_UserLoginBox.Text, "@", $GUI_UserUPNSuffixesBox.Text) }
    $null = $window.ShowDialog()
}

Main