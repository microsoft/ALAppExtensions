namespace Microsoft.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;

query 36952 Dimensions
{
    Access = Internal;
    Caption = 'Power BI Dimensions';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'dimension';
    EntitySetName = 'dimensions';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GeneralLedgerSetup; "General Ledger Setup")
        {
            dataitem(Dim1; Dimension)
            {
                DataItemLink = Code = GeneralLedgerSetup."Global Dimension 1 Code";
                column(Dim1Code; "Code")
                {
                }
                column(Dim1Name; Name)
                {
                }
                column(Dim1Caption; "Code Caption")
                {
                }
                dataitem(Dim2; Dimension)
                {
                    DataItemLink = Code = GeneralLedgerSetup."Global Dimension 2 Code";
                    column(Dim2Code; "Code")
                    {
                    }
                    column(Dim2Name; Name)
                    {
                    }
                    column(Dim2Caption; "Code Caption")
                    {
                    }
                    dataitem(Dim3; Dimension)
                    {
                        DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 3 Code";
                        column(Dim3Code; "Code")
                        {
                        }
                        column(Dim3Name; Name)
                        {
                        }
                        column(Dim3Caption; "Code Caption")
                        {
                        }
                        dataitem(Dim4; Dimension)
                        {
                            DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 4 Code";
                            column(Dim4Code; "Code")
                            {
                            }
                            column(Dim4Name; Name)
                            {
                            }
                            column(Dim4Caption; "Code Caption")
                            {
                            }
                            dataitem(Dim5; Dimension)
                            {
                                DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 5 Code";
                                column(Dim5Code; "Code")
                                {
                                }
                                column(Dim5Name; Name)
                                {
                                }
                                column(Dim5Caption; "Code Caption")
                                {
                                }
                                dataitem(Dim6; Dimension)
                                {
                                    DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 6 Code";
                                    column(Dim6Code; "Code")
                                    {
                                    }
                                    column(Dim6Name; Name)
                                    {
                                    }
                                    column(Dim6Caption; "Code Caption")
                                    {
                                    }
                                    dataitem(Dim7; Dimension)
                                    {
                                        DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 7 Code";
                                        column(Dim7Code; "Code")
                                        {
                                        }
                                        column(Dim7Name; Name)
                                        {
                                        }
                                        column(Dim7Caption; "Code Caption")
                                        {
                                        }
                                        dataitem(Dim8; Dimension)
                                        {
                                            DataItemLink = Code = GeneralLedgerSetup."Shortcut Dimension 8 Code";
                                            column(Dim8Code; "Code")
                                            {
                                            }
                                            column(Dim8Name; Name)
                                            {
                                            }
                                            column(Dim8Caption; "Code Caption")
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