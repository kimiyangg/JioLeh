import "package:jio_leh/models/open_jio_event.dart";
import "package:jio_leh/models/user_friend.dart";
import "package:jio_leh/services/open_jio_service.dart";

class FakeOpenJioService extends OpenJioService {
  FakeOpenJioService({
    this.sentEvents = const [],
    this.receivedEvents = const [],
    this.savedEventId = "fake-event-id",
    this.throwInviteNotFound = false,
  });

  // Defaults live in the constructor, so each test sets only what it cares about.
  List<OpenJioEvent> sentEvents;
  List<OpenJioEvent> receivedEvents;
  String savedEventId;
  bool throwInviteNotFound;

  int saveEventCalls = 0;
  int updateEventCalls = 0;
  int deleteEventCalls = 0;
  int respondToInviteCalls = 0;
  OpenJioEvent? lastUpdatedEvent;
  String? lastDeletedEventId;
  InviteStatus? lastResponse;
  void Function()? lastOnNew;

  @override
  Future<String> saveEvent(OpenJioEvent event) async {
    saveEventCalls++;
    return savedEventId;
  }

  @override
  Future<void> updateEvent(OpenJioEvent event) async {
    updateEventCalls++;
    lastUpdatedEvent = event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deleteEventCalls++;
    lastDeletedEventId = eventId;
  }

  @override
  Future<List<OpenJioEvent>> getSentEvents(
    List<UserFriend> allFriends,
  ) async => sentEvents;

  @override
  Future<List<OpenJioEvent>> getReceivedEvents() async => receivedEvents;

  @override
  Future<void> respondToInvite(
    String eventId,
    InviteStatus status,
  ) async {
    respondToInviteCalls++;
    lastResponse = status;
    if (throwInviteNotFound) {
      throw const InviteNotFound();
    }
  }

  @override
  void Function() subscribeToInvites(void Function() onNew) {
    lastOnNew = onNew;
    return () {};
  }
}
