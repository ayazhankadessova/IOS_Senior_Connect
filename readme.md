## How can we teach Digiotal Literacy to Elderly? (Brainstorming)


1. Smartphone Basics 
* 3-4 lessons on how to use a smartphone 
2. Digital Literacy 
* Watch 5 videos on how to stay safe online / Read 
* Answer quiz questions
* I will get videos from Youtube : https://www.youtube.com/watch?v=_LElWqXi7Ag&list=PLcetZ6gSk9682A7ZAZq2s9IqB-y8Ng63e
3. Social Media 
* Learn how to use WhatsApp/Facebook/Instagram basics 
* Quizes
4. IoT Integration 
* Integrate IoT functionalities to enhance user experience, such as smart home device controls
and health monitoring tools. Provide interactive tutorials on how to use common IoT devices, tailored for seniors.

https://www.youtube.com/watch?v=D_jj5Awr0Kc&list=PLPRhQEDGqsFC4NL3DiYpPVnDKP9o1dnTw&index=2

## Bugs:

- Important

## Middle: Functionality
- [ ] EventRow cant show properly Registered/Not -> fix how it is updated => [Low Priority]

## Easy: Functionality
- [x] When u just open Events page => show some events
- [ ] Add pagination => [Infinite scroll] => [Low priority]

## Easy: Better UI
- [x] Lesson description -> align left

## Idk: from logs:

```
nw_read_request_report [C3] Receive failed with error "Operation timed out"

```
- When scroll events [High Priority] => no need to init stuff for every events
```
🔄 EventDetailViewModel initialized for event: 673acf01fa25a7cae7a258fd
🔄 EventDetailViewModel initialized for event: 673acf01fa25a7cae7a258fe
🔄 EventDetailViewModel initialized for event: 673acf01fa25a7cae7a258ff
🔄 EventDetailViewModel initialized for event: 673acf01fa25a7cae7a25900
🔄 Updating AuthService in EventDetailViewModel
🔄 Updating AuthService in EventDetailViewModel
🔄 Updating AuthService in EventDetailViewModel
🔄 Updating AuthService in EventDetailViewModel
```

## Plan 

### 13 Nov 
- [ ] Smartphone Basics Frontend
- [ ] Smartphone Basics Backend
- [ ] Make Backend more readable -> diff folders PLSSSS AYAZHHHH
- [x] fetched lessons from the backend
- [x] move lesson models to diff folder!
- [x] add save progress button
- [x] let user update the progress whenever they want!

### 14 Nov

- [x] Complete lessons w multiple sections
- [x] fix get progress backed
- [x] Get data properly from the backend on stepProgress and show it 

### 15 nov
- [x] Refresh Updates
- [x] Dont show "u wanna see quick tutorial thing" every time 

### 16-17 Nov
- [ ] Try out CRUD Opers
- [ ] fix date on the backend
- [ ] reg/unreg
- online/offline
- based on areas/region
- language
- categories for each
- REGISTERED?

### 18 nov
- add toast when reg/unreg 
- online/not check
- [x] add video url
- [x] Add lessons
- [x] Add image to every event -> now it is just random
- [x] Add Sample Events (10)
- [x] check lessons
- [x] filter by category
- [x] tab that shows registered events


## 19 nov
- [x] Make quick actions workable
- [ ] put events code to diff folders for better readability
- [ ] update after added help req 
- [x] can see reqs
- [x] Mentor help request
- [x] Make help view look better
- [x] Add delete mentorship request

## 20 nov
- [x] Added DigitalLiteracy courses 
- [x] add placeholder image for youtube vids
- [x] remove second help request sheet
- [x] overall Progress to home page
- [x] remove unnecessary padding from help request
- [ ] put events code to diff folders for better readability
- [x] update after added help req 
- [ ] Helper for category colors -> make more reusable bc in EventRow & in EventDetail
- [ ] Add quizes to digitalLiteracy
- [ ] When scroll events [High Priority] => no need to init stuff for every events


## 21 nov
- add Social media lessons

## Backlog:
- [ ] Your Learning Progress for every category ?
- [ ] Make Detail View look good like in drafts
- [ ] go thru the code, remove lengthy views!
- [ ] Add image for vidoes, can we show them in the same page ?
- [ ] Remove help requested and remove save for later (just change backebd) -> Easy 




Ideas:
1. Add offline support?


