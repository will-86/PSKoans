function Get-KoanHelp {
    <#
    .SYNOPSIS
    Get-KoanHelp provides access to more extensive documentation on the koan topics.

    .DESCRIPTION
    Get-KoanHelp calls Get-Help -Online on the koan topic(s) that you specify to provide further assistance and more
    extensive documentation, should you need it or be interested in it.

    .PARAMETER Topic
    Specify one or more topics to query the help pages for.

    .EXAMPLE
    Get-KoanHelp -Topic AboutArrays

    Opens the about_Arrays help documentation for you to read through in your default browser.

    .EXAMPLE
    Get-KoanHelp AboutArrays

    Opens the about_Arrays help documentation in your default browser.

    .NOTES
    Only koan files with a preset HelpUri in their [CmdletBinding()] attribute will be functional with this command.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [Alias('Koan', 'File')]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

                $Values = Get-PSKoanLocation | Get-ChildItem -Recurse -Filter '*.Koans.ps1' |
                Sort-Object -Property BaseName |
                ForEach-Object {
                    $_.BaseName -replace '\.Koans$'
                }

                return @($Values) -like "$WordToComplete*"
            }
        )]
        [string[]]
        $Topic
    )
    process {
        if ($MyInvocation.ExpectingInput) {
            $Topic = , $Topic
        }

        foreach ($Item in $Topic) {
            try {
                Get-ChildItem -Path $script:ModuleRoot -Filter "${Item}*" -Recurse |
                Select-Object -First 1 |
                Get-Help -Online -Name { $_.FullName } -ErrorAction Stop
            }
            catch [System.Management.Automation.PSInvalidOperationException] {
                $ErrorDetails = @{
                    ExceptionType    = 'System.Management.Automation.PSInvalidOperationException'
                    ExceptionMessage = 'Could not find an online HelpUri for the specified Topic(s).'
                    InnerException   = $_.Exception
                    ErrorId          = 'PSKoans.NoHelpUri'
                    ErrorCategory    = 'InvalidOperation'
                    TargetObject     = $Item -join ','
                }
                $ErrorRecord = New-PSKoanErrorRecord @ErrorDetails

                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    }
}