permissionset 4763 "Contoso Coffee Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Contoso Coffee Admin';

    IncludedPermissionSets = "Contoso Coffee -Read";

    Permissions =
        tabledata "Assisted Company Setup Status" = m,
        tabledata "Capacity Constrained Resource" = im,
        tabledata "Capacity Unit of Measure" = i,
        tabledata "Company Information" = m,
        tabledata "G/L Account" = i,
        tabledata "Gen. Business Posting Group" = i,
        tabledata "Gen. Product Posting Group" = i,
        tabledata "General Posting Setup" = im,
        tabledata "Inventory Posting Group" = i,
        tabledata "Item Category" = i,
        tabledata "Item Journal Batch" = im,
        tabledata "Item Journal Line" = i,
        tabledata "Item Journal Template" = im,
        tabledata "Item Tracking Code" = i,
        tabledata "Item Unit of Measure" = i,
        tabledata "Item Variant" = i,
        tabledata "Item" = i,
        tabledata "Location" = i,
        tabledata "Machine Center" = im,
        tabledata "Manufacturing Demo Account" = IMD,
        tabledata "Manufacturing Demo Data Setup" = IMD,
        tabledata "No. Series Line" = i,
        tabledata "No. Series" = i,
        tabledata "Order Promising Setup" = im,
        tabledata "Production BOM Header" = im,
        tabledata "Production BOM Line" = i,
        tabledata "Production BOM Version" = m,
        tabledata "Routing Header" = im,
        tabledata "Routing Line" = i,
        tabledata "Routing Link" = i,
        tabledata "Routing Version" = im,
        tabledata "Scrap" = i,
        tabledata "Shop Calendar Working Days" = i,
        tabledata "Shop Calendar" = i,
        tabledata "Stop" = i,
        tabledata "Tax Area" = i,
        tabledata "Unit of Measure" = i,
        tabledata "Vendor" = i,
        tabledata "Work Center Group" = i,
        tabledata "Work Center" = im,
        tabledata "Work Shift" = i;
}
