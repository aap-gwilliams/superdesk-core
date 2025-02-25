Feature: Highlights

    @auth
    Scenario: Create highlight
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
		When we post to "content_templates"
        """
        {"template_name": "default highlight", "template_type": "highlights",
         "data": {"body_html": "{% for item in items %} <h2>{{ item.headline }}</h2> {{ item.body_html }} <p></p> {% endfor %}"}
        }
        """
        Then we get response code 201
        When we post to "highlights"
        """
        {"name": "highlight1", "desks": ["#desks._id#"], "groups": ["group one", "group two"], "template": "#content_templates._id#"}
        """
        Then we get response code 201
        Then we get new resource
        """
        {"name": "highlight1", "desks": ["#desks._id#"], "groups": ["group one", "group two"], "template": "#content_templates._id#"}
        """
        When we get "highlights"
        Then we get list with 1 items
        """
        {"_items": [{"name": "highlight1", "desks": ["#desks._id#"], "groups": ["group one", "group two"], "template": "#content_templates._id#"}]}
        """

    @auth
    Scenario: Create duplicate highlight
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
        When we post to "highlights"
        """
        {"name": "highlight1", "desks": ["#desks._id#"]}
        """
        When we post to "highlights"
        """
        {"name": "Highlight1", "desks": ["#desks._id#"]}
        """
        Then we get response code 400

    @auth
    Scenario: Update highlight
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
        When we post to "content_templates"
        """
        {"template_name": "default highlight", "template_type": "highlights",
         "data": {"body_html": "{% for item in items %} <h2>{{ item.headline }}</h2> {{ item.body_html }} <p></p> {% endfor %}"}
        }
        """
        Then we get response code 201
        When we post to "highlights"
        """
        {"name": "highlight1"}
        """
        When we patch "highlights/#highlights._id#"
        """
        {"name": "highlight changed", "desks": ["#desks._id#"], "groups": ["group one", "group two"], "template": "#content_templates._id#"}
        """
        Then we get OK response
        When we get "highlights"
        Then we get list with 1 items
        """
        {"_items": [{"name": "highlight changed", "desks": ["#desks._id#"], "groups": ["group one", "group two"], "template": "#content_templates._id#"}]}
        """
        When we patch "highlights/#highlights._id#"
        """
        {"template": ""}
        """
        Then we get OK response
        When we get "highlights"
        Then we get list with 1 items
        """
        {"_items": [{"name": "highlight changed", "desks": ["#desks._id#"], "groups": ["group one", "group two"]}]}
        """

    @auth
    Scenario: Mark item for highlights
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
        When we post to "highlights"
        """
        {"name": "highlight1", "desks": ["#desks._id#"]}
        """
        Then we get new resource
        """
        {"name": "highlight1", "desks": ["#desks._id#"]}
        """
        When we post to "archive"
		"""
		[{"headline": "test"}]
		"""
		When we post to "marked_for_highlights"
		"""
		[{"highlights": "#highlights._id#", "marked_item": "#archive._id#"}]
		"""
		Then we get new resource
        """
        {"highlights": "#highlights._id#", "marked_item": "#archive._id#"}
        """
        When we get "archive"
        Then we get list with 1 items
        """
        {"_items": [{"headline": "test", "highlights": ["#highlights._id#"],
                     "_etag": "#archive._etag#"}]}
        """

        When we post to "marked_for_highlights"
        """
        [{"highlights": "#highlights._id#", "marked_item": "marked_item": "#archive._id#"}]
        """
        And we get "archive"
        Then we get list with 1 items
        """
        {"_items": [{"highlights": [], "_etag": "#archive._etag#"}]}
        """

    @auth
    Scenario: Mark not available item for highlights
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
        When we post to "highlights"
        """
        {"name": "highlight1", "desks": ["#desks._id#"]}
        """
		When we post to "marked_for_highlights"
		"""
		[{"highlights": "#highlights._id#", "marked_item": "not_available_item_id"}]
		"""
		Then we get new resource
        """
        {"_id": "__any_value__","highlights": "#highlights._id#", "marked_item": "not_available_item_id"}
        """
        When we get "archive"
        Then we get list with 0 items


    @auth
    Scenario: Delete highlights
        Given "desks"
		"""
		[{"name": "desk1"}]
		"""
        When we post to "highlights"
        """
        {"name": "highlight1", "desks": ["#desks._id#"]}
        """
        When we post to "archive"
		"""
		[{"headline": "test"}]
		"""
		Then we get new resource
        """
        {"headline": "test"}
        """
		When we post to "marked_for_highlights"
		"""
		[{"highlights": "#highlights._id#", "marked_item": "#archive._id#"}]
		"""
		When we delete "highlights/#highlights._id#"
		Then we get response code 204
		When we get "highlights"
        Then we get list with 0 items
		When we get "archive"
        Then we get list with 1 items
        """
        {"_items": [{"headline": "test", "highlights": []}]}
        """

    @auth
    Scenario: Delete a highlight that has an item that is in another highlight
         Given "desks"
		"""
		[{"_id": "1", "name": "desk1"}]
		"""
        Given "highlights"
        """
        [{"_id": "111111111111111111111111", "name": "highlight1", "desks": ["1"]},
        {"_id":  "222222222222222222222222", "name": "highlight2", "desks": ["1"]}]
        """
        When we post to "archive"
		"""
		[{"headline": "test"}]
		"""
		Then we get new resource
        """
        {"headline": "test"}
        """
		When we post to "marked_for_highlights"
		"""
		[{"highlights": "111111111111111111111111", "marked_item": "#archive._id#"},
		{"highlights": "222222222222222222222222", "marked_item": "#archive._id#"}]
		"""
		When we get "archive"
        Then we get list with 1 items
        """
        {"_items": [{"headline": "test", "highlights": ["111111111111111111111111", "222222222222222222222222"]}]}
        """
		When we delete "highlights/111111111111111111111111"
		Then we get response code 204
		When we get "highlights"
        Then we get list with 1 items
		When we get "archive"
        Then we get list with 1 items
        """
        {"_items": [{"headline": "test", "highlights": ["222222222222222222222222"]}]}
        """

    @auth
    Scenario: Generate text item from highlights using default template
        Given "desks"
        """
        [{"name": "desk1"}]
        """
        Given "archive"
        """
        [
            {"guid": "item1", "type": "text", "headline": "item1", "body_html": "<p>item1 first</p><p>item1 second</p>", "task": {"desk": "#desks._id#"}, "state": "published"},
            {"guid": "item2", "type": "text", "headline": "item2", "body_html": "<p>item2 first</p><p>item2 second</p>", "task": {"desk": "#desks._id#"}, "state": "published"}
        ]
        """
		When we post to "archive"
		"""
		{   "guid": "package",
		    "type": "composite",
		    "headline": "highlights",
		    "groups": [{
		        "id": "root",
		        "refs": [{
		            "idRef": "main"
		        }]
		    }, {
		        "id": "main",
		        "refs": [{
		            "residRef": "item1"
		        }, {
		            "residRef": "item2"
		        }]
		    }],
		    "task": {
		        "desk": "#desks._id#"
		    }
		}
		"""

        Then we get new resource
        """
        {"_id": "__any_value__", "type": "composite", "headline": "highlights"}
        """

        When we post to "generate_highlights"
        """
        {"package": "package"}
        """

        Then we get new resource
        """
        {"_id": "__any_value__",
        "type": "text",
        "headline": "highlights",
        "_current_version": 1,
        "body_html": "\n<h2>item1</h2>\n<p>item1 first</p>\n<p></p>\n\n<h2>item2</h2>\n<p>item2 first</p>\n<p></p>\n"}
        """

        When we get "/archive"
        Then we get list with 2 items

        When we post to "generate_highlights"
        """
        {"package": "package", "preview": true}
        """
        Then we get new resource
        """
        {"type": "text"}
        """

    @auth
    Scenario: Generate text item from highlights using custom template
        Given "desks"
        """
        [{"name": "desk1"}]
        """
        Given "archive"
        """
        [
            {"guid": "item1", "type": "text", "headline": "item1", "body_html": "<p>item1 first</p><p>item1 second</p>", "task": {"desk": "#desks._id#"}, "state": "fetched"},
            {"guid": "item2", "type": "text", "headline": "item2", "body_html": "<p>item2 first</p><p>item2 second</p>", "task": {"desk": "#desks._id#"}, "state": "fetched"}
        ]
        """
        When we post to "content_templates"
        """
        {
            "template_name": "default highlight",
            "template_type": "highlights",
            "data": {
                "headline": "custom headline",
                "slugline": "custom slugline",
                "byline": "custom byline",
                "abstract": "custom abstract",
                "priority": 1,
                "urgency": 1,
                "language": "nb-NO",
                "body_html": "<b>custom highlight template</b>\n{% for item in items %} <h2>{{ item.headline }}</h2> {{ item.body_html | first_paragraph() }} <p></p>{% endfor %}",
                "fields_meta": {
                    "body_html": {
                        "draftjsState": [{
                            "blocks": [{
                                "key": "7sg3m",
                                "text": "test some text",
                                "type": "unstyled",
                                "depth": 0,
                                "inlineStyleRanges": [],
                                "entityRanges": [],
                                "data": {
                                    "MULTIPLE_HIGHLIGHTS": {}
                                }
                            }]
                        }]
                    }
                }
            }
        }
        """
        Then we get response code 201
        When we post to "highlights"
        """
        {"name": "highlight custom", "template": "#content_templates._id#"}
        """
        Then we get response code 201
        When we post to "archive"
        """
        {   "guid": "package",
            "type": "composite",
            "headline": "highlights",
            "highlight": "#highlights._id#",
            "groups": [{
                "id": "root",
                "refs": [{
                    "idRef": "main"
                }]
            }, {
                "id": "main",
                "refs": [{
                    "residRef": "item1"
                }, {
                    "residRef": "item2"
                }]
            }],
            "task": {
                "desk": "#desks._id#"
            }
        }
        """
        Then we get response code 201
        Then we get new resource
        """
        {"_id": "__any_value__", "type": "composite", "headline": "custom headline", 
         "slugline": "custom slugline", "byline": "custom byline", "abstract": "custom abstract",
         "priority" : 1, "urgency" : 1, "language" : "nb-NO"}
        """

        When we post to "generate_highlights"
        """
        {"package": "package", "export": true}
        """

        Then we get new resource
        """
        {"_id": "__any_value__", "type": "text", "headline": "custom headline", 
         "slugline": "custom slugline", "byline": "custom byline", "abstract": "custom abstract",
         "priority" : 1, "urgency" : 1, "language" : "nb-NO",
         "body_html": "<b>custom highlight template</b>\n <h2>item1</h2> <p>item1 first</p> <p></p> <h2>item2</h2> <p>item2 first</p> <p></p>",
         "fields_meta": "__none__"}
        """

        When we get "/archive"
        Then we get list with 4 items

        When we post to "generate_highlights"
        """
        {"package": "package", "preview": true,  "export": true}
        """
        Then we get new resource
        """
        {"type": "text"}
        """

        When we post to "generate_highlights"
        """
        {"package": "package"}
        """
        Then we get response code 403

    @auth
    Scenario: Prepopulate highlights when creating a package
        Given highlights
        When we create highlights package
        Then we get new package with items


    @auth
    Scenario: Generate text item from highlights using filter
        Given "desks"
        """
        [{"name": "desk1"}]
        """
        Given "archive"
        """
        [
            {"guid": "item1", "type": "text", "headline": "item1", "task": {"desk": "#desks._id#"}, "state": "published"},
            {"guid": "item2", "type": "text", "headline": "item2", "body_html": "<p>item2 first</p><p>item2 second</p>", "task": {"desk": "#desks._id#"}, "state": "published"}
        ]
        """
		When we post to "archive"
		"""
		{   "guid": "package",
		    "type": "composite",
		    "headline": "highlights",
		    "groups": [{
		        "id": "root",
		        "refs": [{
		            "idRef": "main"
		        }]
		    }, {
		        "id": "main",
		        "refs": [{
		            "residRef": "item1"
		        }, {
		            "residRef": "item2"
		        }]
		    }],
		    "task": {
		        "desk": "#desks._id#"
		    }
		}
		"""

        Then we get new resource
        """
        {"_id": "__any_value__", "type": "composite", "headline": "highlights"}
        """

        When we post to "generate_highlights"
        """
        {"package": "package"}
        """

        Then we get new resource
        """
        {"_id": "__any_value__",
        "type": "text",
        "headline": "highlights",
        "body_html": "\n<h2>item1</h2>\n\n<p></p>\n\n<h2>item2</h2>\n<p>item2 first</p>\n<p></p>\n"}
        """

        When we get "/archive"
        Then we get list with 2 items

        When we post to "generate_highlights"
        """
        {"package": "package", "preview": true}
        """
        Then we get new resource
        """
        {"type": "text"}
