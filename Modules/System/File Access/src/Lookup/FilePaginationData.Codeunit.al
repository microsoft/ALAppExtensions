codeunit 70006 "File Pagination Data"
{
    var
        Marker: Text;
        EndOfListing: Boolean;

    procedure SetMarker(NewMarker: Text)
    begin
        Marker := NewMarker;
    end;

    procedure GetMarker(): Text
    begin
        exit(Marker);
    end;

    procedure SetEndOfListing(NewEndOfListing: Boolean)
    begin
        EndOfListing := NewEndOfListing;
    end;

    procedure IsEndOfListing(): Boolean
    begin
        exit(EndOfListing);
    end;
}
