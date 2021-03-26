query 4700 "VAT Group Submission Status"
{
    QueryType = API;
    Caption = 'vatGroupSubmissionStatus', Locked = true;
    APIPublisher = 'microsoft';
    APIGroup = 'vatGroup';
    APIVersion = 'v1.0';
    EntityName = 'vatGroupSubmissionStatus';
    EntitySetName = 'vatGroupSubmissionStatus';
    // The representative can have multiple rows with the same "No." in the table "VAT Group Submission Header".
    // Only the one with the latest date needs to be retrieved
    OrderBy = Descending(submittedOn);
    TopNumberOfRows = 1;

    elements
    {
        dataitem(VATGroupSubmissionHeader; "VAT Group Submission Header")
        {
            column(no; "No.")
            {
            }
            column(submittedOn; "Submitted On")
            {

            }
            column(groupMemberId; "Group Member ID")
            {
            }
            column(vatGroupReturnNo; "VAT Group Return No.")
            {
            }
            dataitem(VATReportHeader; "VAT Report Header")
            {
                DataItemTableFilter = "VAT Report Config. Code" = const("VAT Return");
                DataItemLink = "No." = VATGroupSubmissionHeader."VAT Group Return No.";
                SqlJoinType = InnerJoin;

                column(status; Status)
                {
                }
            }
        }
    }
}