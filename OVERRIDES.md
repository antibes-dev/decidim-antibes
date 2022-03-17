# Overiden files

### Load decidim-awesome assets only if dependency is present

* app/views/layouts/decidim/_head.html.erb:33

### Fix meetings orders in indexes

* app/controllers/decidim/meetings/meetings_controller.rb
* app/controllers/decidim/meetings/directory/meetings_controller.rb

### Fix meetings registration serializer

* app/serializers/decidim/meetings/registration_serializer.rb

### Fix UserAnswersSerializer for CSV exports

* lib/decidim/forms/user_answers_serializer.rb
