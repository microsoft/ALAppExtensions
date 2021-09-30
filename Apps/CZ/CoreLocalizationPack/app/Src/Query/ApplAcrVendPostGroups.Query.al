#if not CLEAN18
#pragma warning disable AL0432
query 11701 "Appl.Acr. Vend.Post.Groups CZL"
{
    QueryType = Normal;
    ObsoleteState = Pending;
    ObsoleteReason = 'This query will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    elements
    {
        dataitem(Sibling_Application_Entry; "Detailed Vendor Ledg. Entry")
        {
            DataItemTableFilter = "Entry Type" = filter(2);
            column(Entry_No_; "Entry No.")
            {
            }
            dataitem(Appl_Across_Post_Groups_Entry; "Detailed Vendor Ledg. Entry")
            {
                DataItemLink = "Transaction No." = Sibling_Application_Entry."Transaction No.";
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Entry Type" = filter(2);

                column(Entry_No_2; "Entry No.")
                {
                }
                column(Vendor_Posting_Group; "Vendor Posting Group")
                {
                }
                dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
                {
                    DataItemLink = "Entry No." = Appl_Across_Post_Groups_Entry."Applied Vend. Ledger Entry No.", "Vendor Posting Group" = Appl_Across_Post_Groups_Entry."Vendor Posting Group";
                    SqlJoinType = FullOuterJoin;

                    column(Count_)
                    {
                        ColumnFilter = Count_ = filter(0);
                        Method = Count;
                    }
                }
            }
        }
    }
}
#endif