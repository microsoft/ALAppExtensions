permissionset 4764 "Contoso Coffee -Read"
{
    Access = Public;
    Assignable = true;
    Caption = 'Contoso Coffee Read';

    IncludedPermissionSets = "Contoso Coffee - Objects";

    Permissions =
        tabledata "Assisted Company Setup Status" = r,
        tabledata "Capacity Constrained Resource" = r,
        tabledata "Capacity Unit of Measure" = r,
        tabledata "Company Information" = r,
        tabledata "G/L Account" = r,
        tabledata "Gen. Business Posting Group" = r,
        tabledata "Gen. Product Posting Group" = r,
        tabledata "General Posting Setup" = r,
        tabledata "Inventory Posting Group" = r,
        tabledata "Item Category" = r,
        tabledata "Item Journal Batch" = r,
        tabledata "Item Journal Line" = r,
        tabledata "Item Journal Template" = r,
        tabledata "Item Tracking Code" = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Item Variant" = r,
        tabledata "Item" = r,
        tabledata "Location" = r,
        tabledata "Machine Center" = r,
        tabledata "Manufacturing Demo Account" = R,
        tabledata "Manufacturing Demo Data Setup" = R,
        tabledata "No. Series Line" = r,
        tabledata "No. Series" = r,
        tabledata "Order Promising Setup" = r,
        tabledata "Production BOM Header" = r,
        tabledata "Production BOM Line" = r,
        tabledata "Production BOM Version" = r,
        tabledata "Req. Wksh. Template" = r,
        tabledata "Requisition Wksh. Name" = r,
        tabledata "Routing Header" = r,
        tabledata "Routing Line" = r,
        tabledata "Routing Link" = r,
        tabledata "Routing Version" = r,
        tabledata "Scrap" = r,
        tabledata "Shop Calendar Working Days" = r,
        tabledata "Shop Calendar" = r,
        tabledata "Source Code Setup" = r,
        tabledata "Stop" = r,
        tabledata "Tax Area" = r,
        tabledata "Unit of Measure" = r,
        tabledata "Vendor" = r,
        tabledata "Work Center Group" = r,
        tabledata "Work Center" = r,
        tabledata "Work Shift" = r;
}