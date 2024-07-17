import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Modal,
  FlatList,
  StyleSheet,
} from 'react-native';
import { CmpScreenConfig } from '../../src/types/CmpScreenConfig';

interface ScreenConfigSelectProps {
  selectedValue: CmpScreenConfig | null;
  onValueChange: (value: CmpScreenConfig) => void;
}

const CmpScreenConfigOptions = [
  { label: 'Full Screen', value: CmpScreenConfig.FullScreen },
  { label: 'Half Screen Bottom', value: CmpScreenConfig.HalfScreenBottom },
  { label: 'Half Screen Top', value: CmpScreenConfig.HalfScreenTop },
  { label: 'Center Screen', value: CmpScreenConfig.CenterScreen },
  { label: 'Small Center Screen', value: CmpScreenConfig.SmallCenterScreen },
  { label: 'Large Top Screen', value: CmpScreenConfig.LargeTopScreen },
  { label: 'Large Bottom Screen', value: CmpScreenConfig.LargeBottomScreen },
];

const ScreenConfigSelect: React.FC<ScreenConfigSelectProps> = ({
  selectedValue,
  onValueChange,
}) => {
  const [modalVisible, setModalVisible] = useState(false);

  const handleSelect = (value: CmpScreenConfig) => {
    onValueChange(value);
    setModalVisible(false);
  };

  return (
    <View>
      <TouchableOpacity
        onPress={() => setModalVisible(true)}
        style={styles.selectButton}
      >
        <Text style={styles.selectButtonText}>
          {selectedValue
            ? CmpScreenConfigOptions.find(
                (option) => option.value === selectedValue
              )?.label
            : 'Select an option'}
        </Text>
      </TouchableOpacity>

      <Modal
        transparent={true}
        visible={modalVisible}
        animationType="slide"
        onRequestClose={() => setModalVisible(false)}
      >
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <FlatList
              data={CmpScreenConfigOptions}
              keyExtractor={(item) => item.value}
              renderItem={({ item }) => (
                <TouchableOpacity
                  onPress={() => handleSelect(item.value)}
                  style={styles.option}
                >
                  <Text style={styles.optionText}>{item.label}</Text>
                </TouchableOpacity>
              )}
            />
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  selectButton: {
    padding: 16,
    backgroundColor: '#ddd',
    borderRadius: 4,
    marginVertical: 8,
  },
  selectButtonText: {
    fontSize: 16,
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modalContent: {
    width: '80%',
    backgroundColor: '#fff',
    borderRadius: 4,
    padding: 16,
  },
  option: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#ddd',
  },
  optionText: {
    fontSize: 16,
  },
});

export default ScreenConfigSelect;
