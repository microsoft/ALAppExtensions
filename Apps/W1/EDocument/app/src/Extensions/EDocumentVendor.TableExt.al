#pragma warning disable AA0247
tableextension 6165 "E-Document Vendor" extends Vendor
{
    fields
    {
        field(6101; "Receive E-Document To"; Enum "E-Document Type")
        {
            DataClassification = SystemMetadata;
            InitValue = "Purchase Order";
            ValuesAllowed = "Purchase Order", "Purchase Invoice";
        }
    }
}