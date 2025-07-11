enumextension 139614 "Shpfy Bulk Operation Type" extends "Shpfy Bulk Operation Type"
{
    value(139614; AddProduct)
    {
        Caption = 'Add Product';
        Implementation = "Shpfy IBulk Operation" = "Shpfy Mock Bulk ProductCreate";
    }
}