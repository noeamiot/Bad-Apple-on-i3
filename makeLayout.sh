# This script creates the layout file for i3 to load, the parameter is the size (resolution) you want
sub=$(( $1 - 1 ))
echo '{
    "border": "none",
    "current_border_width": 0,
    "floating": "auto_off",
    "geometry": {
       "height": 316,
       "width": 484,
       "x": 0,
       "y": 0
    },
    "marks": [],
    "name": "amiotnoe@ido:~",
    "percent": 0.21875,
    "swallows": [
       {
       "class": "^XTerm$"
       }
    ],
    "type": "con"
}
'
echo '
{
    // splith split container with 1 children
    "border": "normal",
    "floating": "auto_off",
    "layout": "splith",
    "marks": [],
    "percent": 0.5625,
    "type": "con",
    "nodes": [
        {
            // splith split container with '$1' children
            "border": "normal",
            "floating": "auto_off",
            "layout": "splith",
            "marks": [],
            "percent": 1,
            "type": "con",
            "nodes": ['
for ((i =0; i <= $sub; i++)); do
    echo '
                {
                    // splitv split container with '$1' children
                    "border": "normal",
                    "floating": "auto_off",
                    "layout": "splitv",
                    "marks": [],
                    "percent": 0.05,
                    "type": "con",
                    "nodes": ['
    for ((j = 0; j <= $sub; j++)); do
        echo '                        {
                            "border": "none",
                            "current_border_width": 0,
                            "floating": "auto_off",
                            "geometry": {
                               "height": 316,
                               "width": 484,
                               "x": 0,
                               "y": 0
                            },
                            "marks": [],
                            "name": "amiotnoe@ido:~",
                            "percent": 0.05,
                            "swallows": [
                               {
                               "title": "^badapple'$((i * $1 + j))'$"
                               }
                            ],
                            "type": "con"
                        }';
         [[ $j -eq $sub ]] && { echo ""; } || { echo ","; }
     done
     echo '                    ]
                }';
     [[ $i -eq $sub ]] && { echo ""; } || { echo ","; }

done
echo '            ]
        }
    ]
}
'
      
echo '
{
    "border": "none",
    "current_border_width": 0,
    "floating": "auto_off",
    "geometry": {
       "height": 316,
       "width": 484,
       "x": 0,
       "y": 0
    },
    "marks": [],
    "name": "amiotnoe@ido:~",
    "percent": 0.21875,
    "swallows": [
       {
       "class": "^XTerm$"
       }
    ],
    "type": "con"
}'
