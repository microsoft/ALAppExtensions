namespace Microsoft.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Setup;


query 36951 "Dimension Sets"
{
    // ***This is an internal query which is no longer directly exposed to Power BI***
    // ***This Query is used internally to refresh and store data in Table 57699 - Power BI Dim. Set Entry***
    // ***Query 57737 - Power BI Dim. Entries is exposed to Power BI instead***

    Access = Internal;
    Caption = 'Power BI Dimension Sets';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(General_Ledger_Setup; "General Ledger Setup")
        {
            dataitem(Dimension_Set_Entry; Microsoft.Finance.Dimension."Dimension Set Entry")
            {
                SqlJoinType = CrossJoin;
                column(Dimension_Set_ID; "Dimension Set ID")
                {
                }
                column(Value_Count)
                {
                    Method = Count;
                }
                column(SystemModifiedAt; SystemModifiedAt)
                {
                }
                dataitem(Dimension_1; Microsoft.Finance.Dimension."Dimension Set Entry")
                {
                    DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 1 Code";
                    column(Dimension_1_Value_Code; "Dimension Value Code")
                    {
                    }
                    column(Dimension_1_Value_Name; "Dimension Value Name")
                    {
                    }
                    dataitem(Dimension_2; Microsoft.Finance.Dimension."Dimension Set Entry")
                    {
                        DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 2 Code";
                        column(Dimension_2_Value_Code; "Dimension Value Code")
                        {
                        }
                        column(Dimension_2_Value_Name; "Dimension Value Name")
                        {
                        }
                        dataitem(Dimension_3; Microsoft.Finance.Dimension."Dimension Set Entry")
                        {
                            DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 3 Code";
                            column(Dimension_3_Value_Code; "Dimension Value Code")
                            {
                            }
                            column(Dimension_3_Value_Name; "Dimension Value Name")
                            {
                            }
                            dataitem(Dimension_4; Microsoft.Finance.Dimension."Dimension Set Entry")
                            {
                                DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 4 Code";
                                column(Dimension_4_Value_Code; "Dimension Value Code")
                                {
                                }
                                column(Dimension_4_Value_Name; "Dimension Value Name")
                                {
                                }
                                dataitem(Dimension_5; Microsoft.Finance.Dimension."Dimension Set Entry")
                                {
                                    DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 5 Code";
                                    column(Dimension_5_Value_Code; "Dimension Value Code")
                                    {
                                    }
                                    column(Dimension_5_Value_Name; "Dimension Value Name")
                                    {
                                    }
                                    dataitem(Dimension_6; Microsoft.Finance.Dimension."Dimension Set Entry")
                                    {
                                        DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 6 Code";
                                        column(Dimension_6_Value_Code; "Dimension Value Code")
                                        {
                                        }
                                        column(Dimension_6_Value_Name; "Dimension Value Name")
                                        {
                                        }
                                        dataitem(Dimension_7; Microsoft.Finance.Dimension."Dimension Set Entry")
                                        {
                                            DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 7 Code";
                                            column(Dimension_7_Value_Code; "Dimension Value Code")
                                            {
                                            }
                                            column(Dimension_7_Value_Name; "Dimension Value Name")
                                            {
                                            }
                                            dataitem(Dimension_8; Microsoft.Finance.Dimension."Dimension Set Entry")
                                            {
                                                DataItemLink = "Dimension Set ID" = Dimension_Set_Entry."Dimension Set ID", "Dimension Code" = General_Ledger_Setup."Shortcut Dimension 8 Code";
                                                column(Dimension_8_Value_Code; "Dimension Value Code")
                                                {
                                                }
                                                column(Dimension_8_Value_Name; "Dimension Value Name")
                                                {
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}