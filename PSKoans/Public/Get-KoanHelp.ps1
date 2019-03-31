function Get-KoanHelp {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [string[]]
        $Topic
    )
    process {
        if ($MyInvocation.ExpectingInput) {
            $Topic = , $Topic
        }

        foreach ($Item in $Topic) {
            Get-ChildItem -Path $script:ModuleRoot -Filter "${Item}*" -Recurse |
            Select-Object -First 1 |
            Get-Help -Online -Name { $_.FullName }
        }
    }
}