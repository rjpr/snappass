.PHONY: dev prod run test

dev: dev-requirements.txt
	pip install -r dev-requirements.txt

prod: requirements.txt
	pip install -r requirements.txt

run: prod
	FLASK_DEBUG=1 FLASK_APP=snappass.main NO_SSL=True venv/bin/flask run

test:
	PYTHONPATH=snappass venv/bin/nosetests -s tests

translations:
	docker run --rm \
	  -v $(PWD)/babel.cfg:/usr/src/snappass/babel.cfg:ro \
	  -v $(PWD)/snappass:/usr/src/snappass/snappass \
	  -w /usr/src/snappass \
	  rjpr/snappass bash -c " \
	    pybabel extract -F babel.cfg -o messages.pot . && \
	    pybabel update -i messages.pot -d snappass/translations && \
	    pybabel compile -d snappass/translations && \
	    rm messages.pot"