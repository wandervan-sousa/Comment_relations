# Comment Relations

This script has the purpose of inserting comments in tables, views and materialized views. An example of using this script would be to comment on relations that will be archived.

## How to use?

Preferably a ".txt" file is required, this file should contain the name of the relationships that will be commented following the pattern "schemaname.relation_name"

for example:

public.relation1\
public.relation2\
public.v_relation3


Inside the script, insert your credentials and the comments according to your preference.

## Usage
It may be necessary to grant execute permission to the script, this can be done with:
```bash
sudo chmod a+x comment_relations.sh
```

Now in the terminal, let's run the script remembering that the file path must be passed, for example:


```bash
bash comment_relations.sh example.txt
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

