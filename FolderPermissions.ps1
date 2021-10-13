function FolderAccess{
    $fName = $var_txtPath.Text
    
    $folderAccess = (Get-ACL -Path $fName).Access

    $accessName = $folderAccess.IdentityReference.Value -split "\\"
    #store results for access type and final results to be put in csv
    $result = @()
    $result2 = @()
    
    foreach ($item in $accessName){
        #you can exclude groups by adding -and $item -ne "EXCLUDENAME"
        if($item -ne "YOURDOMAIN" -and $item -ne "NT AUTHORITY" -and $item -ne "SYSTEM" -and $item -ne "BUILTIN"){
            $result = $result += $item   
        } 
    }
    
    $var_pbStatus.Maximum = $result.Count
    foreach ($item in $result){
        $var_pbStatus.Value++
        try { 
        $result2 = $result2 += Get-ADGroupMember -Identity $item | Select-Object Name  | Sort-Object Name -ErrorAction stop 
        } 
        catch{
        echo $result2 = $result2 +=$item 
        }

    }
                                #change below for where you want results saved - you can also modify name or make it dynamic based off folder being checked!
    $result2 | export-csv -Path "FileResult.csv"

}
    #add assembly to run a WFP xaml file
 Add-Type -AssemblyName PresentationFramework
 $xamlFile = "MainWindow.xaml"
 #get content of xaml file
 $inputXML = Get-Content $xamlFile -Raw
 $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*','<Window'
 [XML]$XAML = $inputXML
 #setup reader to read the xaml file
 $reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{
    $window = [Windows.Markup.XamlReader]::Load($reader)
    }catch {
    Write-Warning $_.Exception
    throw
    }
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{
try{
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }catch{
        throw
    }
}


#gets all elements from the windows presentation from and displays it
Get-Variable var_*

$var_btnRun.Add_Click({

   FolderAccess $var_txtPath.Text

})
#shows the windows presentation form to the user
$Null = $window.ShowDialog()
