[subPrefix] & "-" &
If ( [Company - ID#] < 10, 
  "00"& ToText ( [Company - ID#] ),
  If ( [Company - ID#] >= 10 and [Company - ID#] < 100,
    "0"& ToText ( [Company - ID#] ),
    ToText ( [Company - ID#] )
  )
)&
"-"&
If ( ToNumber ( [ID] ) < 10,
  If ( Length ( [ID] ) < 2 and not ( Begins ( [ID], "0" ) ), 
    "00"& [ID],
    If ( Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
      "00"& Right ( [ID], 1 )
    )
  ),
  If ( ToNumber ( [ID] ) >= 10 and ToNumber ( [ID] ) < 100,
    If ( Length ( [ID] ) < 3 and not ( Begins ( [ID], "00") ),
      "0"& [ID],
      If ( Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
        "0"& Right ( [ID], 2 )
      )
    )
  ),
  If ( ToNumber ( [ID] ) >= 100,
    If ( Length ( [ID] ) < 4 and not ( Begins ( [ID], "000" ) ),
      [ID],
      If ( Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
        Right ( [ID], 3 )
      )
    )
  )
)
==================
S-003-002
THF10N0D0522200974
==================
If ( ToNumber ( [ID] ) < 10 and Length( [ID] ) < 2 and not( Begins( [ID], "0" ) ), 
     "00"& [ID],
     If ( ( ToNumber ( [ID] ) >= 10 and ToNumber ( [ID] ) < 100 ) and Length( [ID] ) < 3 and not( Begins( [ID], "0") ),
          "0"& [ID],
          If ( Length( [ID] ) > 3 or Begins( [ID], "0" ),
               Right( [ID], 3 ),
               [ID]
          )
     )
)
==================
If ( 
  ToNumber ( [ID] ) < 10,
    If ( Length ( [ID] ) < 2 and not ( Begins ( [ID], "0" ) ), 
        "00"& [ID],
      Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
        "00"& Right ( [ID], 1 )
    ),
  ToNumber ( [ID] ) >= 10 and ToNumber ( [ID] ) < 100,
    If ( Length ( [ID] ) < 3 and not ( Begins ( [ID], "00") ),
        "0"& [ID],
      Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
        "0"& Right ( [ID], 2 )
    ),
  ToNumber ( [ID] ) >= 100,
    If ( Length ( [ID] ) < 4 and not ( Begins ( [ID], "000" ) ),
        [ID],
      Length ( [ID] ) > 3 or Begins ( [ID], "0" ),
        Right ( [ID], 3 )
    )
)
