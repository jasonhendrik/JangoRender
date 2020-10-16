#created by jasonhendrik (www.jasonhendrik.com)
#see readme for pre-render steps!

#This script is released under the Creative Commons 4.0 Attribution license.

Function AfterEffectsBGrendering() {

#$runningInstances =	0

Add-Type -AssemblyName System.Windows.Forms

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 

    InitialDirectory = [Environment]::GetFolderPath('Desktop') 

    Filter = 'AfterEffects (*.aep, *.)|*.aep'
}
$null = $FileBrowser.ShowDialog()

$SelectedFile = Get-Content -Raw $FileBrowser.FileName

$SelectedFile_simple = Get-Content $FileBrowser.FileName

#regex step 1 of 2
if ($SelectedFile -match '(?<=Ropt)(?s)(.*$)') {

 $outputFolder_step1 = $Matches[1]

} 

#regex step 2 of 2 -  get render folder for frame count?
if ($outputFolder_step1 -match '(?<=\"fullpath\":\")(.*)(?=\",\"platform\")') 
{

    $outputFolder = $Matches[1]

    $outputFolder = $outputFolder -replace ("\\.","\")

} 


$AEproject = $FileBrowser.FileName

$numOfFrames  = Read-Host 'How many frames?'

$numOfInstances = Read-Host 'How many Instances?'

$argsList = "-project $AEproject"

$Target = "aerender"

    #while this "controller-process" is running & frames arent there, KEEP GOING!
	while ($numOfFrames -le (Get-ChildItem $outputFolder | Measure-Object ).Count) 
    {
        
	    While (Get-Process JANGORENDER) 
        {
	
	        #begin instances
	        do 
               {
		        
                #count process names aerender
		        $Process = (Get-Process | Where-Object {$_.ProcessName -eq $Target} | Measure-Object).Count 
		
		        #if process drops out create another one
		        if ($Process -lt $numOfInstances){
		
	    	    Start-Process -FilePath $Target -ArgumentList $argsList
    	   	   }
		
	    }
   
    until($Process -eq $numOfInstances )
		
	}

Stop-Process -processname $Target

}

Exit

}

AfterEffectsBGrendering | Out-Null

