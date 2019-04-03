class Blank {
    [string] ToString() {
        return [string]::Empty
    }

    [bool] op_Equals([object] $other) {
        return $false
    }
}
