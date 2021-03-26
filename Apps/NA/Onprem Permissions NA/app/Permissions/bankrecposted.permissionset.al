permissionset 27005 "BANKREC-POSTED"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Posted Bank Recs';

    Permissions = tabledata "Bank Comment Line" = Ri,
                  tabledata "Posted Bank Rec. Header" = Ri,
                  tabledata "Posted Bank Rec. Line" = Ri;
}
