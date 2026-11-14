Describe 'Test root disk resized' {
    It "C: should fill its disk" {
        $partition = Get-Partition -DriveLetter C
        $maxSize = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
        ($maxSize - $partition.Size) | Should -BeLessThan 100MB
    }
}
