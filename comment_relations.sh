#!/bin/bash

#This script automates the insertion of comments in tables, views and materialized views, from a file containing "schema_name.relation"

# Set the PostgreSQL password as an environment variable
export PGPASSWORD="<Password>"

# Database connection parameters
DB_USER="<User>"
DB_NAME="<Database>"
DB_HOST="<Host>"
DB_PORT="<Port>"

# Get the current date in the format YYYY-MM-DD
CURRENT_DATE=$(date +"%Y-%m-%d")

# Check if an input file path is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide path to input file."
    exit 1
fi

# Read lines from the input file provided as an argument
while IFS= read -r line; do
    # Extract schema and object names from the line
    SCHEMA_NAME=$(echo "$line" | cut -d'.' -f1)
    OBJECT=$(echo "$line" | cut -d'.' -f2)

    # Get the database object type (table, view, materialized view)
    OBJECT_NAME=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT CASE WHEN relkind = 'r' THEN 'table' WHEN relkind = 'v' THEN 'vision' WHEN relkind = 'm' THEN 'materialized_view' ELSE 'desconhecido' END FROM pg_class WHERE relname = '$OBJECT' AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = '$SCHEMA_NAME')")

    # Choose an action based on the type of the database object
    case $OBJECT_NAME in
    "table")
        # Retrieve existing comment (if any) for the table
        EXISTING_COMMENT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT obj_description('$SCHEMA_NAME.$OBJECT'::regclass, 'pg_class')")

        # Prepare the new comment for the table
        if [ -z "$EXISTING_COMMENT" ]; then
            NEW_COMMENT="<add the desired comment>"
        else
            NEW_COMMENT="$EXISTING_COMMENT\n\n\n<add the desired comment>"
        fi

        # Set the comment for the table
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "COMMENT ON TABLE $SCHEMA_NAME.$OBJECT IS E'${NEW_COMMENT//\'/\\\'}';"
        echo "Comment added or updated for $SCHEMA_NAME.$OBJECT."
        ;;
    "vision")

        # Set the comment for the view
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "COMMENT ON VIEW $SCHEMA_NAME.$OBJECT IS '<add the desired comment';>"
        echo "Added or updated comment for view $SCHEMA_NAME.$OBJECT."
        ;;
    "materialized_view")

        # Set the comment for the materialized view
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "COMMENT ON MATERIALIZED VIEW $SCHEMA_NAME.$OBJECT IS '<add the desired comment';>"
        echo "Added or updated comment for materialized view $SCHEMA_NAME.$OBJECT."
        ;;
    *)
    
        # Handle unknown object types
        echo "Unknown OBJECT type: $OBJECT_NAME"
        ;;
    esac

done <"$1"
