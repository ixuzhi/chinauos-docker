.PHONY: clean
# all start stop

clean:
	rm -rf *.log

start:
	docker-compose -f docker-compose.yaml up -d --build
