dotnet
{
    assembly(System.Management)
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b03f5f7f11d50a3a';

        type(System.Management.ManagementObjectSearcher; MTD_ManagementObjectSearcher) { }
        type(System.Management.ManagementObject; MTD_ManagementObject) { }
        type(System.Management.PropertyData; MTD_PropertyData) { }
    }
}