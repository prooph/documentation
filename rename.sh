#!/bin/bash

for filename in projections/*.md; do
echo "{
        'files': '$filename',
        'src': 'projections',
        'dest': '${filename%.md}'
      },"
done

# Now upload to s3, deleting any items that no longer exist
# aws s3 sync --delete $DEPLOY_DIR s3://$BUCKET

# Finally, upload the blog directory specifically to force the content-type
# aws s3 cp "$DEPLOY_DIR/blog" s3://$BUCKET/blog --recursive --content-type "text/html"

# Cleanup
# rm -r $DEPLOY_DIR
