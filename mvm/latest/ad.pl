use Ante::Deluvian::Dialog;

$d = Ante::Deluvian::Dialog->new(
  platform  => "MSWIN",
  drawframe => 1,
  title     => "Title of Window",
  prompt    => "Please make your choice:",
  # record    => 1,
  # replay    => "C:/temp/addialog/<username>_<pid>.txt",
);

$fdir  = $d->dselect();
print "You have selected directory $fdir ...\n";

$fname = $d->fselect($fdir);
print "You have selected file $fname ...\n";

@aLst = ( "A" .. "Z", "a" .. "z" );
@aRes = $d->listbox(\@aLst, select => "multi");

$rd = $d->radiolist([
              [ "List of radio buttons", 1, ],
              [ "red",    "RED", 0 ],
              [ "green",  "GRN", 1 ],
              [ "blue",   "BLU", 0 ],
              [ "yellow", "YLW", 0 ],
      ]);

$d->alert([
      "Press <RETURN> to continue ...",
      "Attention! This is considered to be",
      "an alert box (see below) ...",
      "The recent radio list resulted in $rd",
]);

if (-T $fname) {
  $inpf = IO::File->new($fname);
  $d->textbox($inpf);
}
else {
  $d->textbox($fname);
}
