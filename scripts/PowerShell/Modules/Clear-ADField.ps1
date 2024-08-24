function private:Clear-MemberOf {

    param (
        [Parameter (Mandatory = $true, HelpMessage = "Tableaux des utilisateurs à retiré l'attribut AD MemberOf")]
        [System.Array]$allUsers
    )


}

function Clear-ADField {
    <#
    
    #>

    param(
        [Parameter (Mandatory = $true, HelpMessage = "Tableau des utilisateurs a effacer un attribut AD")]
        [System.Array]$allUsers,

        [Parameter (Mandatory = $true, HelpMessage = "Champ AD à retirer des utilisateurs")]
        [string]$adField
    )

    switch ($adField) {
        "EmployeeID" { Clear-EmployeeID }
        "EmployeeType" { Clear-EmployeeType }
        "MemberOf" { Clear-MemberOF  }
        Default {}
    }

}