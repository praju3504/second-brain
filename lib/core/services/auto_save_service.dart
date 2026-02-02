import 'dart:async';
import 'package:rxdart/rxdart.dart';

/// Service for auto-saving content with debouncing
class AutoSaveService {
  final Duration _debounceDuration;
  final Future<void> Function(String content) _onSave;
  
  final _contentSubject = BehaviorSubject<String>();
  StreamSubscription? _subscription;
  
  bool _isSaving = false;
  DateTime? _lastSaved;
  String? _lastContent;
  
  AutoSaveService({
    required Future<void> Function(String content) onSave,
    Duration debounceDuration = const Duration(seconds: 2),
  })  : _onSave = onSave,
        _debounceDuration = debounceDuration {
    _setupAutoSave();
  }

  void _setupAutoSave() {
    _subscription = _contentSubject
        .debounceTime(_debounceDuration)
        .distinct()
        .listen((content) async {
      if (content == _lastContent) return;
      
      _isSaving = true;
      try {
        await _onSave(content);
        _lastSaved = DateTime.now();
        _lastContent = content;
      } catch (e) {
        // Error handled by caller
      } finally {
        _isSaving = false;
      }
    });
  }

  /// Trigger a content change for auto-save
  void updateContent(String content) {
    _contentSubject.add(content);
  }

  /// Force an immediate save without debouncing
  Future<void> saveNow(String content) async {
    if (content == _lastContent) return;
    
    _isSaving = true;
    try {
      await _onSave(content);
      _lastSaved = DateTime.now();
      _lastContent = content;
    } finally {
      _isSaving = false;
    }
  }

  /// Get the current save status
  bool get isSaving => _isSaving;

  /// Get the last saved timestamp
  DateTime? get lastSaved => _lastSaved;

  /// Get status text
  String get statusText {
    if (_isSaving) return 'Saving...';
    if (_lastSaved != null) {
      final diff = DateTime.now().difference(_lastSaved!);
      if (diff.inSeconds < 60) return 'Saved just now';
      if (diff.inMinutes < 60) return 'Saved ${diff.inMinutes}m ago';
      return 'Saved ${diff.inHours}h ago';
    }
    return '';
  }

  /// Check if there are unsaved changes
  bool hasUnsavedChanges(String currentContent) {
    return currentContent != _lastContent;
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _contentSubject.close();
  }
}

/// Service for managing drafts in local storage
class DraftService {
  final String _draftKey;
  
  DraftService({required String draftKey}) : _draftKey = draftKey;

  /// Save draft to local storage (placeholder - implement with shared_preferences)
  Future<void> saveDraft(String content) async {
    // TODO: Implement with shared_preferences
    // For now, this is a placeholder
  }

  /// Load draft from local storage (placeholder - implement with shared_preferences)
  Future<String?> loadDraft() async {
    // TODO: Implement with shared_preferences
    return null;
  }

  /// Clear draft from local storage
  Future<void> clearDraft() async {
    // TODO: Implement with shared_preferences
  }
}
